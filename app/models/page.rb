class Page
  include Mongoid::Document 
  #include Mongoid::Timestamps
  #include Mongoid::Tree
  #include Mongoid::Tree::Traversal
  #include Mongoid::Tree::Ordering
  
  attr_accessible :title, 
                  :path_name, 
                  :meta_title, 
                  :meta_keywords, 
                  :meta_description, 
                  :filter,
                  :current_state, 
                  :layout_id
  
  field :title, :type => String
  field :path_name, :type => String
  field :meta_title, :type => String
  field :meta_keywords, :type => String
  field :meta_description, :type => String
  field :filter, :type => Filter
  embeds_one :current_state
  references_and_referenced_in_many :editors, :class_name => "User"
  referenced_in :layout
  referenced_in :created_by, :class_name => "User", :inverse_of => :pages_created
  referenced_in :updated_by, :class_name => "User", :inverse_of => :pages_updated
  #embeds_many :page_parts 
  accepts_nested_attributes_for :current_state
  
  validates :title,
            :presence => true,
            :uniqueness => true
            
  validates :path_name,
            :uniqueness => true, :allow_blank => true, :allow_nil => true
  
  validates :meta_title,
            :uniqueness => true, :allow_blank => true, :allow_nil => true
  
  validates_presence_of :filter, :current_state, :layout, :created_by, :updated_by
  
  before_validation :set_filter, :format_title
  after_validation :uri_escape_path_name
  #before_destroy :move_children_to_parent
  
  private 
  def format_title
    self.title.strip! unless self.title.nil?
  end
  
  def set_filter
    self.filter = Filter.find("html") if self.filter.nil?
  end
  
  def uri_escape_path_name
    if self.path_name.nil?
      self.path_name = URI.escape(self.title)
    else
      self.path_name = URI.escape(self.path_name.strip)
    end
  end
end
