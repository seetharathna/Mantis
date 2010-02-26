class WishListsController < ApplicationController
  ensure_authenticated_to_facebook  
  before_filter :owner_of_the_profile,:only => [:delete, :edit]
 
  def show
    @wish_list = WishList.find(params[:id]) rescue nil
    if @wish_list
      @categories = @wish_list.categories(:order => 'desc created_at')
      #@items = @wish_list.categories.map{|c| c.category_id}
      #@category =  @items.last 
    end
  end

  def new
    @user = facebook_user
    @wish_list = WishList.new
  end

  def edit
    @wish_list = WishList.find(params[:id])
  end
 
  def create
    @user = facebook_user
    @wish_list = WishList.new(params[:wish_list])
    @wish_list.user = user

    if @wish_list.save
      flash.now[:notice] = "Wish list has been created successfully."
      redirect_to(wish_list_path(@wish_list))
    else
      flash.now[:error] = "Make sure that all required fields are entered."
      @wish_list = nil
      render :action => 'new'
    end
 
  end


  def update
    @wish_list = WishList.find(params[:id])
    if @wish_list.update_attributes(params[:wish_list])
       flash[:notice] = 'Category was successfully updated.'
       redirect_to(wish_list_path(@wish_list))
    else
       render :action => 'edit'
    end
  end

   
  def destroy
    @wish_list = WishList.find(params[:id])
    @wish_list.destroy
    redirect_to(categories_path)
  end

  def add_to_wishlist
    @wish_list = user.wish_list
    category = Category.find(params[:category_id])
  
    unless @wish_list.blank?
      @wish_list.categories << category
      redirect_to(wish_list_path(@wish_list))
    else
      flash[:notice] = 'Please create wish list first.'
      redirect_to(new_wish_list_path)
    end  
  end

  def publish_to_friends
    @wish_list = user.wish_list
    @category = Category.find(params[:category])
    @user = facebook_session.user
    if @user.has_permissions?('publish_stream')
      facebook_session.user.publish_to(facebook_session.user, :message => 'has added new product categories to wishlist.',:action_links => [
      :text => "#{facebook_session.user.name}'s wishlist",
      :href => "http://apps.facebook.com/littlesurprizes/wish_lists/#{@wish_list.id}"],
      :attachment => {  :name => "#{@category.name}",
                        :description => "#{@category.description}",
                        :media => [{ :type => 'image',
                                      :src => "http://69.164.192.249:3012/#{@category.avatar.url(:thumb)}",      
                                      :href => "http://apps.facebook.com/littlesurprizes"}]
                                                }
                        )
      redirect_to(wish_list_path(@wish_list))
    else
      render :action => 'grant_permission'
    end  
  end
  
  
  def grant_permission
  end
  
  def remove_category
    @wish_list =  user.wish_list
    @wish_list.categories.delete(Category.find(params[:id]))
    redirect_to(wish_list_path(@wish_list))
  end
  
private  

  def owner_of_the_profile
    @wish_list = WishList.find(params[:id])
    if @wish_list.user.facebook_id == facebook_session.user.to_i
      return true
    else
      redirect_to(wish_list_path(@wish_list))
      flash[:error] = "you are not authorised to acess this page"
    end
  end
 
  def user
    User.find_or_create_by_facebook_id(facebook_session.user.to_i)
  end

  def facebook_user
    facebook_session.user
  end

  
end
