class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  ## private method
  def list_to_dict dict
    return dict.map {|key,value| key}
  end
  private :list_to_dict

  def index
    # print(params)
    @sort_header = params.key?(:sort) ? params[:sort] : nil
    @selected_ratings = (params[:ratings].nil?) ? nil : params[:ratings]

    ## there is a special case where the user clear all the rating.
    ## we have to clear the session
    if( @sort_header == nil && @selected_ratings == nil && params['commit'] != nil )
      session['ratings'] = nil
      ## total new page. clear all session
      # if( params['commit'] == nil)
      #   session['sort'] = nil
      # end
    end
    
    # print "Selected rating #{@selected_ratings}"
    session_ratings = session['ratings']
    session_sort = session['sort']
    ## inital rating where nothing is set
    if(@selected_ratings == nil && @sort_header == nil && session_ratings == nil && session_sort == nil)
      @movies = Movie.all
    ## if url is proper
    elsif( @sort_header != nil && @selected_ratings != nil )
      @movies = Movie.order(@sort_header).where('rating in (?)', list_to_dict(@selected_ratings) ).all
    ## if rating is null in session as well as url
    elsif( @sort_header != nil && (@selected_ratings == nil && session_ratings == nil))
      @movies = Movie.order(@sort_header).all
    ## if sort header is null in session as well as url
    elsif(@selected_ratings!=nil && (session_sort== nil && @sort_header == nil))
      print("hello")
      @movies = Movie.where('rating in (?)',  list_to_dict(@selected_ratings) ).all
    ## redirect case
    else
      @sort_header = @sort_header == nil ? session_sort : @sort_header
      @selected_ratings = @selected_ratings == nil ? session_ratings : @selected_ratings
      redirect_to action:'index', sort: @sort_header, ratings: @selected_ratings 
    end
    session['ratings'] = @selected_ratings
    session['sort'] = @sort_header
    

    # if( @sort_header != nil && selected_ratings != nil &&@selected_ratings.length != 0)
    #   @movies = Movie.order(@sort_header).where('rating in (?)', @selected_ratings).all
    # elsif(@selected_ratings.length != 0)
    #   @movies = Movie.where('rating in (?)', @selected_ratings).all  
    # elsif( @sort_header != nil)
    #   @movies = Movie.order(@sort_header).all
    # else 
    #   @movies = Movie.all
    # end

    ## get all different ratings
    @all_ratings = Movie.pluck("DISTINCT rating")
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
