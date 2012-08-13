class Perspective < ActiveRecord::Base
  belongs_to  :default_for_shape_set, :class_name => 'ShapeSet', :foreign_key => 'default_for_shape_set_id'
  belongs_to  :style_set, :class_name => 'Perspective'
  has_many    :points_of_view, :class_name => 'Perspective', :foreign_key => 'style_set_id', :dependent => :destroy
  has_many    :own_region_styles, :class_name => 'RegionStyle', :foreign_key => 'perspective_id', :dependent => :destroy
  has_many    :styled_regions, :through => :own_region_styles, :source => :region
  validates_presence_of :name
  validates_uniqueness_of :name
  
  def regions
    has_external_styles? ? style_set.regions : styled_regions
  end
  
  def make_default_for shape_set
    shape_set.default_perspective_attr = self
  end
  
  def active_regions
    # only returns regions via styles which are included/not-orphaned
    has_external_styles? ? style_set.regions : own_region_styles.select{|rs| !rs.orphaned}.map{|rs| rs.region}
  end
  
  def has_external_styles?
    # does this Perspective have region_styles itself or just point to another Perspective's region_styles?
    style_set.kind_of? Perspective
  end
  
  def use_external_styles other_perspective
    other_perspective.points_of_view << self
  end
  
  def region_styles
    has_external_styles? ? style_set.region_styles : own_region_styles
  end
  
  def style_for region
    if regions.include? region
      region_styles.select { |rs| rs.region_id == region.id }.first
    else
      return false
    end
  end
  
  def disown_region_if_styled region
    if rs = style_for(region)
      rs.disown
    end
  end
  
  def include_regions new_regions
    [*new_regions].each { |nr| update_or_create_region_style :region => nr }
  end
  
  def update_or_create_region_style params
    if rs = style_for(params[:region])
      params.select! { |k,_| [:colour,:transparency,:label].include? k }
      params[:orphaned] = false
      rs.update_attributes params
    else
      region_styles << RegionStyle.create( :colour         => params[:colour],
                                           :transparency   => params[:transparency],
                                           :label          => params[:label],
                                           :orphaned       => false,
                                           :region_id      => params[:region].id)
    end
  end
  
end
