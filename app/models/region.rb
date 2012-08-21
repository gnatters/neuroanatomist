class Region < ActiveRecord::Base
  belongs_to  :thing
  has_one :node, :through => :thing
  has_and_belongs_to_many :super_compositions, :class_name => 'Decomposition'
  has_many :decompositions,     :dependent => :destroy
  has_many :region_definitions, :dependent => :destroy
  has_many :region_styles,      :dependent => :destroy
  has_many :sub_regions,        :through => :decompositions
  has_many :shape_sets,         :through => :region_definitions
  has_many :perspectives,       :through => :region_styles
  
  validates_uniqueness_of :name
  
  after_update :invalidate_caches
  
  alias :definitions :region_definitions
  
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
    attributes["name"] or label
  end
  
  def has_name?
    attributes["name"] ? true : false
  end
  
  def hash_partial shape_set, cascade
    hp = Hash[
      attrs: Hash[
        id:             self.id,
        name:           self.name,
        thing:          (self.thing ? self.thing.id : nil),
        decompositions: self.decompositions.map(&:hash_partial)
      ]
    ]
    hp[:shapes] = self.definition_for(shape_set).shapes.map(&:id) if cascade
    return hp
  end
  
  def description_hash
    Hash[ name: name,
          definitions: region_definitions.map(&:label_string) ]
  end
  
  def self.create_from_description description
    description = JSON.load(description) if description.kind_of? String
    new_region = Region.create :name => (description["name"] or description[:name])
    (description["definitions"] or description[:definitions]).each { |label_string| RegionDefinition.create_from_label_string new_region.id, label_string }
  end
  
  def invalidate_caches
    JaxData.invalidate_caches_with shape_sets: shape_sets, region: self
  end
end
