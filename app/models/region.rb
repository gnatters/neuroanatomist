class Region < ActiveRecord::Base
  belongs_to  :thing
  belongs_to  :default_perspective, :class_name => 'Perspective'
  has_one     :node, :through => :thing
  has_and_belongs_to_many :super_compositions, :class_name => 'Decomposition'
  has_many :decompositions  #,     :dependent  => :destroy
  has_many :region_definitions, :dependent  => :destroy
  has_many :region_styles,      :dependent  => :destroy
  has_many :sub_regions,        :through    => :decompositions
  has_many :shape_sets,         :through    => :region_definitions
  has_many :perspectives,       :through    => :region_styles
  has_many :versions,           :as         => :updated,            :dependent => :destroy
  
  validates_uniqueness_of :name
  validates_presence_of :name
  
  after_update :invalidate_caches
  
  alias :definitions :region_definitions
  
  include VersioningHelper
  
  def version
    Version.init_for self, {} unless current_version
    super
  end
  
  def version_bump size, description, user
    super
    # aggregate versioning
    description = "Region<#{name}>: #{description}"
    perspectives.each { |p|  p.version_bump size, description, user }
    if size == :major
      region_definitions.each { |rd|  rd.version_bump size, description, user }
      region_styles.each { |rs|  rs.version_bump size, description, user }
    end
    # MINOR or MAJOR updates queue a refresh of all server caches that include this region
    shape_sets.each { |ss| VCache.expire_regions ss.id, self.id } if size == :minor or size == :major
  end
  
  def save *args
    saved = super *args
    Version.init_for self, {} if saved
    saved
  end
  
  def decompositions
    # position any unranked decompositions at end of ranking preserving order
    decompositions = Decomposition.where("region_id = ?", id)
    max_rank = (decompositions.map(&:rank).compact.max or 0)
    decompositions = decompositions.select{|d| d[:rank]}.sort + 
                     decompositions.select{|d| !d[:rank]}.map{|d| d.rank = (max_rank+=1); d }
  end
  
  def definition_for shape_set
    (definitions = region_definitions.select{ |x| x.shape_set_id == shape_set.id }).empty? ? false : definitions[0]
  end
  
  def name
    attributes["name"]
  end
  
  def hash_partial shape_set, full=false
    definition = self.definition_for(shape_set)
    hp = Hash[
      id:             self.id,
      version:        definition.version.to_s,
      name:           self.name,
      thing:          (self.thing ? self.thing.id : nil),
      decompositions: self.decompositions.map(&:hash_partial),
    ]
    if full
      hp[:shapes] = definition.shapes.map(&:hash_partial)
    else
      hp[:shapes] = definition.shapes.map(&:id)
    end
    hp
  end
  
  def description_hash
    Hash[ name: name,
          definitions: region_definitions.map(&:label_string) ]
  end
  
  def self.create_from_description description
    description = JSON.load(description) if description.kind_of? String
    (new_region = Region.create :name => (description["name"] or description[:name])) or throw "region couldn't be created"
    (description["definitions"] or description[:definitions]).each { |label_string| RegionDefinition.create_from_label_string new_region.id, label_string }
  end
  
  def invalidate_caches
    VCache.expire_perspectives self.id, false
  end
end
