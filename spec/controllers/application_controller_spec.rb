require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')  

describe "ApplicationController" do
  let(:current_user) { logged_in(:role? => true) }
  controller do
    def index 
      render :nothing => true
    end 
  end
  
  before(:each) do
    cas_faker(current_user.username)
  end
  
  describe "handling cancan call to current_user method" do 
    it "should should receive current_user" do
      controller.should_receive(:current_user).and_return(@current_user)
      get :index
    end
    
    it "current user should return the user" do
      get :index
      assigns[:current_user].should == @current_user
    end
  end  
end 

describe "ApplicationController" do
  let(:current_user) { logged_in(:role? => true) }
  
  controller do 
    def index    
      admin?
      render :nothing => true
    end 
  end 
  
  before(:each) do
    cas_faker(current_user.username)
  end
  
  describe "admin? method" do
    it "should receive admin? method and return true" do
      controller.should_receive(:admin?).and_return(true)
      get :index
    end
    
    it "should receive admin? method and return false" do 
      current_user.stub(:role? => false)
      controller.should_receive(:admin?).and_return(false)
      get :index
    end
  end
end 

describe "ApplicationController" do
  let(:current_user) { logged_in(:role? => true) }

  controller do 
    def index   
      created_updated_by_for(params["page"])
      render :nothing => true
    end 
  end
  
  before(:each) do
    @page = Page.new
    cas_faker(current_user.username)
  end
  
  describe "created_updated_by method" do
    it "should receive created_updated_by method" do
      controller.should_receive(:created_updated_by_for).with(@page)
      get :index, "page" => @page
    end
    
    it "should set created_by and updated_by to the current user" do
      get :index, "page" => @page
      @page.created_by.should == current_user
      @page.updated_by.should == current_user
    end    
  end
end                                