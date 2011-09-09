require 'spec_helper'

describe Admin::SiteAssetsController do

  #for actions
  let(:site) { mock_model(Site, :id => "1") }            
  let(:current_user) { logged_in(:role? => "admin", :site_id => site.id) }
  let(:site_asset) { mock_model("SiteAsset", :site_id => site.id).as_null_object }
  let(:site_assets) { [site_asset]}
  let(:asset_collection) { mock_model(AssetCollection, :site_assets => site_assets, :site_id => site.id).as_null_object }
  
  before(:each) do
    cas_faker(current_user.puid)
    stub_c_site_c_user(site, current_user)  
    AssetCollection.stub(:find).and_return(asset_collection)
  end

  # -- GET Index ----------------------------------------------- 
  describe "GET show" do
    def do_get     
      get :edit, :id => "1", :asset_collection_id => "1"
    end
    
    before(:each) do
      AssetCollection.stub(:where).and_return(site)
      site.stub(:find).and_return(asset_collection)
      asset_collection.stub_chain(:site_assets, :find).and_return(site_asset)
    end
        
    it "should receive accessible_by" do
      AssetCollection.should_receive(:where).and_return(asset_collection)
      do_get
    end 
    
    it "should assign the asset_collection" do
      do_get
      assigns(:asset_collection).should == asset_collection
    end

    it "shuld assign the site_asset" do 
      do_get
      assigns(:site_asset).should == site_asset
    end
    
    it "should render the index template" do
      do_get
      response.should render_template("admin/site_assets/edit")
    end
  end
  
  describe "GET new" do
    def do_get
      get :new, :asset_collection_id => asset_collection.id
    end
    
    before(:each) do
      SiteAsset.stub(:new).and_return(site_asset.as_new_record)
    end
    
    it "should receive new and return a new site_asset" do
      SiteAsset.should_receive(:new).and_return(site_asset)
      do_get
    end         
    
    it "should assign the asset_collection" do
      do_get
      assigns(:asset_collection).should == asset_collection
    end
    
    it "should assign the new site_asset for the view" do
      do_get
      assigns(:site_asset).should == site_asset
    end
    
    it "should render the new template" do
      do_get
      response.should render_template("admin/site_assets/new")
    end
  end
  
  describe "POST create" do
    
    let(:params) { { "name" => "foobar", "asset_cache" => "1/rails.png", "asset" => AssetFixtureHelper.open("rails.png") } }
    
    before(:each) do
      SiteAsset.stub(:new).and_return(site_asset.as_new_record)
    end
    
    def do_post(post_params=params)
      post :create, { "asset_collection_id" => asset_collection.id, "site_asset" => post_params }
    end
    
    it "should create a new site_asset from the params" do
      SiteAsset.should_receive(:new).and_return(site_asset)
      do_post
    end
    
    it "should assign the @site_asset for the view" do
      do_post
      assigns(:site_asset).should == site_asset
    end
    
    it "should assign creator and updator to the current user" do
      controller.should_receive(:creator_updator_set_id).with(site_asset)
      do_post
    end
      
    context "with valid params" do
      it "should save the site_asset to the collection" do
        asset_collection.should_receive(:site_assets).and_return(site_assets)
        site_assets.should_receive(:<<).and_return(site_asset)
        do_post
      end
      
      it "should assign a flash message that the site_asset was saved" do
        do_post
        flash[:notice].should == "Successfully created the asset #{site_asset.name}"
      end
      
      it "should redirect to the admin/site_assets/index" do
        do_post
        response.should redirect_to([:admin, asset_collection])
      end
    end    
    
    context "using asset_cache when asset is nil on redisplay, ie validation fails" do
      it "should set the asset to the asset_cache when the asset_cache is not empty and the asset is nil" do   
        controller.should_receive(:try_site_asset_cache)
        do_post({ "asset_cache" => "1/rails.png"})
      end
    end
    
    context "with invalid params" do
      before(:each) do
        asset_collection.stub(:site_assets).and_return(site_assets)
        site_assets.stub(:<<).and_return(false)
      end
      
      it "should receive save and return false" do
        asset_collection.should_receive(:site_assets).and_return(site_assets)
        site_assets.should_receive(:<<).and_return(false)
        do_post
      end
      
      it "should render the new template" do
        do_post
        response.should render_template("admin/site_assets/new")
      end
    end
  end
  
  describe "GET edit" do
    before(:each) do
      AssetCollection.stub(:where).and_return(asset_collection)
      asset_collection.stub(:site_assets).and_return(site_asset)
      SiteAsset.stub(:find).and_return(site_asset)
    end
    
    def do_get
      get :edit, { "asset_collection_id" => asset_collection.id, "id" => site_asset.to_param }
    end
    
    it "receive prepend_before_filter to assign site_asset instead of cancan load filter " do
      controller.should_receive(:find_site_asset)
      do_get
    end

    it "should assign @site_asset for the view" do
      do_get
      assigns(:site_asset).should == site_asset
    end

    it "should render the template admin/site_asset/edit" do
      do_get
      response.should render_template("admin/site_assets/edit")
    end    
  end

  describe "PUT update" do
    before(:each) do
      AssetCollection.stub(:where).and_return(asset_collection)
      asset_collection.stub(:site_assets).and_return(site_asset)
      SiteAsset.stub(:find).and_return(site_asset)
    end
    
    let(:params) { { "asset_collection_id" => asset_collection.id, "id" => site_asset.to_param, "site_asset" => { "name" => "foobar", "asset_cache" => "1/rails.png", "asset" => AssetFixtureHelper.open("rails.png")}} }
    
    def do_put(put_params=params)
      post :update, put_params
    end
    
    it "receive prepend_before_filter to assign site_asset instead of cancan load filter " do
      controller.should_receive(:find_site_asset)
      do_put
    end
    
    it "should assign @site_asset for the view" do
      do_put
      assigns(:site_asset).should == site_asset
    end
    
    it "should update updator attribute" do
      site_asset.should_receive(:updator_id=).with(current_user.id)
      do_put
    end
    
    describe "with valid params" do
      it "should receive update_attributes and return true" do
        site_asset.should_receive(:update_attributes).and_return(true)
        do_put
      end
      
      it "should assign the flash message with successful update" do
        do_put
        flash[:notice].should == "Successfully updated the asset #{site_asset.name}"
      end
      
      it "should redirect to the site_asset index page" do
        do_put
        response.should redirect_to([:admin, asset_collection])
      end
    end
    
    describe "without valid params" do
      before(:each) do
        site_asset.stub(:update_attributes).and_return(false)
      end
      
      it "should receive update_attributes and return false" do
        site_asset.should_receive(:update_attributes).and_return(false)
        do_put
      end
      
      it "should render the site_asset edit template on failed update" do
        do_put
        response.should render_template("admin/site_assets/edit")
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      AssetCollection.stub(:where).and_return(asset_collection)
      asset_collection.stub(:site_assets).and_return(site_asset)
      SiteAsset.stub(:find).and_return(site_asset)
    end
    
    def do_destroy
      delete :destroy, { "asset_collection_id" => asset_collection.id, "id" => site_asset.to_param }
    end
    
    it "receive prepend_before_filter to assign site_asset instead of cancan load filter " do
      controller.should_receive(:find_site_asset)
      do_destroy
    end
    
    it "should assign the site_asset" do
      do_destroy
      assigns(:site_asset).should == site_asset
    end
     
    context "when destroying site_asset is successful" do
      it "should assign the flash message that the media file was successfully destroyed" do
        do_destroy
        flash[:notice].should == "Successfully deleted the asset #{site_asset.name}"
      end
    
      it "should redirect to admin/site_asset/index when the file is destroyed" do
        do_destroy
        response.should redirect_to([:admin, asset_collection])
      end 
    end
  end
end
