require "spec_helper"

describe HandlebarCms::Mustache::CmsPage do
  let(:site) { Factory(:site)}
  let(:user) { Factory(:user, :site => site) }
  let(:layout) { Factory(:layout, :site => site, :created_by => user, :updated_by => user) }

  before(:each) do
    @controller = CmsSiteController.new
    @page = Factory(:page, :title => "foobar", :site => site, :created_by => user, :updated_by => user)
    @page.page_parts << Factory.build(:page_part, 
                                      :name => "content", 
                                      :content => "define editable text method **strong**", 
                                      :filter_name => "markdown") 
    
    @tag_attr_type = Factory.build(:tag_attr, 'name' => 'type', 'value' => 'text/css')
    @tag_attr_media = Factory.build(:tag_attr, 'name' => 'media', 'value' => 'screen')
  
    @theme_asset_css = Factory(:theme_asset, :site => site, :name => "foobar", :asset => AssetFixtureHelper.open("theme_css.css"), :content_type => "text/css", :tag_attrs => [@tag_attr_type])
    @theme_asset_css_2 = Factory(:theme_asset, :site => site, :name => "baz", :asset => AssetFixtureHelper.open("theme_css.css"), :content_type => "text/css", :tag_attrs => [@tag_attr_type, @tag_attr_media])
    
    @request = mock_model("Request", :host => "test.com", :protocol => 'http')
    
    @controller.instance_variable_set(:@page, @page)
    @controller.instance_variable_set(:@request, @request)
    @controller.instance_variable_set(:@current_site, site)
    @cmsp = HandlebarCms::Mustache::CmsPage.new(@controller)
  end
  
  describe "initialize" do
    it "should set controller ivars to cms_page instance" do
      @cmsp.instance_variable_defined?(:@page).should be_true
    end
    
    it "should set the template to the layout content" do
      @cmsp.template.to_s.should == "Hello, World!"
    end   
  end
  
  describe "yield" do
    it "should return the first page part rendered" do
      @cmsp.yield.to_s.should == "Page Part Hello, World!"
    end
  end
  
  describe "define_editable_text_method" do    
    it "should define the method" do
      @cmsp.respond_to?(:editable_text_content).should be_true
    end
    
    it "should return the page parts contents" do
      if @cmsp.editable_text_content
        @cmsp.editable_text_content.should == "<p>define editable text method <strong>strong</strong></p>\n"    
      end   
    end
  end
  
  describe "it should render with the correct filter" do
    it "should return the page part rendered as markdown" do
      if @cmsp.editable_text_content
        @cmsp.editable_text_content.should == "<p>define editable text method <strong>strong</strong></p>\n"    
      end
    end
    
    it "should return the page part rendered as textile" do
      @page.page_parts.last.filter_name = "textile"
      if @cmsp.editable_text_content
        @cmsp.editable_text_content.should == "<p>define editable text method <b>strong</b></p>"    
      end    
    end
    
    it "should render as plain html" do
      @page.page_parts.last.filter_name = "html"
      if @cmsp.editable_text_content
        @cmsp.editable_text_content.should == "define editable text method **strong**"    
      end
    end
  end 
  
  describe "head" do  
    
    it "should return the page title" do
      @cmsp.title.should == %{<title>#{@page.title}</title>\n}
    end  
    
    it "should return all the css files" do
      @cmsp.stylesheets_all.should == %(<link href="#{@theme_asset_css_2.asset.url}" media="screen" rel="stylesheet" type="text/css" />\n<link href="#{@theme_asset_css.asset.url}" rel="stylesheet" type="text/css" />\n)
    end
    
    it "should return a stylesheet by name" do
      @cmsp.stylesheet_foobar.should == %(<link href="#{@theme_asset_css.asset.url}" rel="stylesheet" type="text/css" />\n)
    end

    describe "meta tags" do
    
      it "should return the meta title from the page" do
        @cmsp.meta_tag_title.should == %(<meta content="title page" name="title" />\n)
      end

      it "should return the meta keywords from the page" do
        @cmsp.meta_tag_keywords.should == %(<meta content="keywords page" name="keywords" />\n)
      end

      it "should return the meta description from the page" do
        @cmsp.meta_tag_description.should == %(<meta content="description page" name="description" />\n)
      end

      it "should return the meta title from the site" do
        @page.meta_tags.where(:name => 'title').first.content = ""
        @cmsp.meta_tag_title.should == %(<meta content="title site" name="title" />\n)
      end

      it "should return the meta keywords from the site" do
        @page.meta_tags.where(:name => 'keywords').first.content = ""
        @cmsp.meta_tag_keywords.should == %(<meta content="keywords site" name="keywords" />\n)
      end

      it "should return the meta description from the site" do
        @page.meta_tags.where(:name => 'description').first.content = ""
        @cmsp.meta_tag_description.should == %(<meta content="description site" name="description" />\n)
      end

      it "should render all the meta_tags" do
        @cmsp.meta_tags.should == %(<meta content="title page" name="title" />
<meta content="keywords page" name="keywords" />
<meta content="description page" name="description" />
)
      end

    end
  end
  
  describe "navigaton" do 
    before(:each) do
      @page2 = Factory(:page, :title => "foobar2", :site => site, :parent => @page, :created_by => user, :updated_by => user)
      @page3 = Factory(:page, :title => "foobar3", :site => site, :parent => @page, :created_by => user, :updated_by => user)
    end
    
    after(:each) do
      Site.all.delete
    end

    it "should return an unordered list of the pages children elements for navigation" do
      template = File.read(File.dirname(__FILE__) + '/templates/nav_child_pages_template.haml')
      rendered = Haml::Engine.new(template, :attr_wrapper => "\"").render(nil, {:page2 => @page2, :page3 => @page3, :parent_page => @page})
      @cmsp.nav_child_pages.should == rendered
    end

    it "should return an unordered list of the pages for the given page name" do
      template = File.read(File.dirname(__FILE__) + '/templates/nav_children.haml')
      rendered = Haml::Engine.new(template, :attr_wrapper => "\"").render(nil, {:page2 => @page2, :page3 => @page3, :parent_page => @page})
      @cmsp.nav_children_foobar.should == rendered
    end

    it "should return an unordered list of the pages siblings for navigation" do
      template = File.read(File.dirname(__FILE__) + '/templates/nav_siblings_and_self.haml')
      rendered = Haml::Engine.new(template, :attr_wrapper => "\"").render(nil, {:page2 => @page2, :page3 => @page3 })
      @cmsp.nav_siblings_and_self_foobar2.should == rendered
    end
  end
end 
