require 'spec_helper'

describe Admin::UsersController do
  
  #for actions
  let(:site) { mock_model(Site, :id => "1") }
  let(:current_user) { logged_in(:role? => "admin", :site_id => site.id) }
  let(:user) { mock_model("User", :site_id => site.id).as_null_object }
  
  before(:each) do
    @current_site = site.stub(:full_subdomain => "foobar.example.com")
    cas_faker(current_user.puid)
    stub_c_site_c_user(site, current_user)
  end
  
  describe "GET index" do
    def do_get     
      get :index
    end
           
    context "when the user is an admin they can view user records" do
      let(:users) { [mock_model("User", :puid => "foo", :role => "admin"),
                    mock_model("User", :puid => "bar", :role => "editor")] } 
      
      before(:each) do
        User.stub(:accessible_by).and_return(users)
      end
      
      it "should receive accessible_by" do
        User.should_receive(:accessible_by).and_return(users)
        do_get
      end
      
      
      it "should assign the found users" do
        do_get
        assigns(:users).should eq(users)
      end
    
      it "should render index template" do
        do_get
        response.should render_template("admin/users/index")
      end  
    end   
  end
  
  describe "GET show" do
    let(:params) {{ :id => "1" }}
    
    before(:each) do
      User.stub(:find).and_return(user)
    end
    
    def do_get
      get :show, :id => "1"
    end
        
    it "should should receive find" do
      User.should_receive(:find).with(params[:id]).and_return(user)
      do_get
    end
    
    it "should assign @user for the view" do
      do_get
      assigns(:user).should eq(user)
    end
    
    it "should render the EDIT template" do
      do_get
      response.should render_template("admin/users/edit")
    end
  end
  
  describe "GET new" do        
    before(:each) do 
      user.as_new_record
      User.stub(:new).and_return(user)   
    end
    
    def do_get     
      get :new
    end  
    
    it "should receive new the new and return a new user" do   
      User.should_receive(:new).and_return(user)
      do_get
    end
  
    it "should assign the found user" do
      do_get
      assigns(:user).should eq(user)
    end
  
    it "should render new template" do
      do_get
      response.should render_template("admin/users/new")
    end
  end     
  
  
  describe "POST create" do 
    let(:params) {{ "user" => { "puid" => "foobar", "firstname" => "foo", "lastname" => "bar", "email" => "foobar@example.com", "role" => "admin" }}}
    
    before(:each) do 
      user.as_new_record   
      controller.stub(:admin?).and_return(true)
      User.stub(:new).and_return(user)
    end  
    
    def do_post       
      post :create, params
    end  
              
    it "should create a new user" do
      User.should_receive(:new).with(params["user"]).and_return(user)
      do_post 
      assigns(:user).should eq(user)                                                              
    end 
    
    it "should assign the puid value" do
      user.should_receive(:puid=).with(params["user"]["puid"])
      do_post
    end
    
    it "should assign the current_site" do
      user.should_receiv(:site=)
    end
    
    it "should assign the role value" do
      user.should_receive(:role=).with(params["user"]["role"])
      do_post
    end
    
    context "when it save the new user successfully" do  
      
      it "should receive save" do
        user.should_receive(:save).and_return(true)
        do_post
      end
      
      it "should should create a flash notice" do 
        do_post
        flash[:notice].should == "Successfully created user profile for #{user.puid}"
      end 
      
      it "should redirect to the admin users path" do
        do_post
        response.should redirect_to(admin_users_path)
      end
    end
    
    context "when the save fails" do                    
      it "should redirect to new template" do 
        user.stub(:save).and_return(false)            
        do_post
        response.should render_template("admin/users/new")
      end
    end 
  end
  
  describe "GET edit" do 
    def do_get    
      get :edit, { :id => user.to_param }
    end     
          
    context "when the user is an admin they can edit user records" do
      before do                                    
        logged_in(:role? => true)
        User.stub(:find).and_return(user)     
      end             
    
      it "should receive find all" do   
        User.should_receive(:find).and_return(user)
        do_get
      end
    
      it "should assign the found users" do
        do_get
        assigns(:user).should eq(user)
      end
    
      it "should render the user to edit" do
        do_get
        response.should render_template("admin/users/edit")
      end  
    end 
  end

  describe "PUT update" do    
    let(:params) {{ "id" => user.to_param, "user" => { "puid" => "baz", "email" => "baz@example.com", "role" => "editor" }}}    
    before(:each) do   
      controller.stub(:admin?).and_return(true) 
      User.stub(:find).and_return(user)
    end  
    
    def do_put 
      put :update, params
    end

    it "should find the record to update" do
      User.should_receive(:find).with(params["id"]).and_return(user)
      do_put
    end 
    
    it "should assign @user for the view" do  
      do_put
      assigns(:user).should eq(user)
    end
    
    
    it "should set the users role when the current_user is an admin" do
      user.should_receive(:role=).with(params["user"]["role"])
      do_put
    end
    
    
    it "should should set attr_accessable attributes" do
      user.should_receive(:update_attributes).with(params["user"])
      do_put
    end
      
    it "should set a flash[:notice] message" do
      do_put
      flash[:notice].should == "Successfully updated user profile for #{user.puid}"
    end         
    
    it "should redirect to INDEX" do
      do_put
      response.should redirect_to(admin_users_path)
    end                                                                       
  
    context "when update_attributes fails" do
      it "should render the edit template" do
        user.stub(:update_attributes).and_return(false)
        do_put  
        response.should render_template("admin/users/edit")
      end
    end
  end
  
  describe "DELETE destroy" do   
    before(:each) do
      User.stub(:find).and_return(user)
      Site.stub(:first).and_return(mock_model(Site))
    end
    
    def do_destroy  
      delete :destroy, :id => "1"
    end
    
    it "should receive the find method and return the user to destroy" do
      User.should_receive(:find).with("1").and_return(user)
      do_destroy
    end 
    
    it "should assign the user for the view" do
      do_destroy
      assigns(:user).should == user
    end    
    
    it "should delete the user account" do
      user.should_receive(:delete).and_return(true)
      do_destroy 
    end
    
    context "when destroying the current logged in user account" do
      before(:each) do
        controller.stub(:current_user?).and_return(true)
      end

      it "should destroy the current session" do
        controller.should_receive(:reset_session)
        do_destroy
      end
      
      it "should redirecto to the index page of the cms" do
        do_destroy
        response.should redirect_to("http://test.host/foobar.example.com")
      end
    end
    
    context "when destroying another users record" do
      before(:each) do
        controller.stub(:current_user?).and_return(false)
      end
      
      it "should set a flash message" do
        do_destroy
        flash[:notice].should == "Successfully deleted user profile for #{user.puid}"
      end

      it "should redirect to admin_users index action" do
        do_destroy
        response.should redirect_to(admin_users_path) 
      end
    end
  end
end
