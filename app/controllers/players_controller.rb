class PlayersController < ApplicationController
  before_action :set_player, only: [:show, :edit, :update, :destroy]
  before_action :current_player
  before_action :admin_access, only: [:index, :show, :edit, :update, :destroy]
  before_action :current_leauge, only: [:standings]
  before_action :standings_array, only: [:standings, :create]
  before_action :not_a_user, only: [:standings]
  #GET /login
  def login_page
  end
  #GET /players
  def index
    @players = Player.all
  end
  #post /login
  def login
     @player = Player.find_by(user_name: params[:user_name])
      # If the player exists AND the password entered is correct.
      if @player && @player.authenticate(params[:password])
         session[:player_id] = @player.id
         @player.first_name
        redirect_to @player, alert: "Welcome, #{@player.first_name}"
        current_player
      else
          # If user's login doesn't work, send them back to the login form.
          # flash[:notice] =
      redirect_to login_path, alert: "unsucessful login"
      end
  end
  def logout
  session[:player_id] = nil
  redirect_to '/', alert: "You are now logged out"
  end
  def standings
    Player.find(1).update(standings_position: 4)
    update_standings
    @players = []
    Player.all.each do |player|
      if player.league_id == @current_player.league_id && player.user_name != "admin"
      @players << player
      end
    end
    @players = @players.sort { |a,b|
      a.standings_position <=> b.standings_position
    }
  end

  # GET /players/1
  # GET /players/1.json
  def show
  end

  # GET /players/new
  def new
    @league_names = []
    @player = Player.new
     League.all.each do |league|
    @league_names << league.league_name
  end
  end

  # GET /players/1/edit
  def edit
  end

  # POST /players
  # POST /players.json
  def create

    @player = Player.new(player_params)
    @player.wins = 0
    @player.losses = 0
    @player.pf = 0
    @player.pa = 0
    @player.win_percentage = 0
    # @player.standings_position = standings_position.max + 1
    current_player
    respond_to do |format|
      if @player.save
        session[:player_id] = @player.id

        format.html { redirect_to @player, notice: 'Player was successfully created.' }
        format.json { render :show, status: :created, location: @player }
      else
        format.html { render :new }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /players/1
  # PATCH/PUT /players/1.json
  def update
    respond_to do |format|
      if @player.update(player_params)
        format.html { redirect_to @player, notice: 'Player was successfully updated.' }
        format.json { render :show, status: :ok, location: @player }
      else
        format.html { render :edit }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /players/1
  # DELETE /players/1.json
  def destroy
    @player.destroy
    respond_to do |format|
      format.html { redirect_to players_url, notice: 'Player was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  #GET /challenge
  # def challenge
  # end
  #POST /challenge
  # def create_challenge
  #   if Player.find_by(user_name: params[:user_name]).nil?
  #     redirect_to '/challenge', alert: "That Player doesn't exists, Please enter players username"
  # elsif @current_player.standings_position  < Player.find_by(user_name: params[:user_name]).standings_position
  #     redirect_to '/challenge', alert: "Sorry your rank is higher than #{Player.find_by(user_name: params[:user_name]).user_name}'s rank"
  #   else
  #     #alert other player that they have been challenged!
  #     redirect_to '/matches/new', alert: "Player has been challenged"
  #
  #   end
  # end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def player_params
      params.require(:player).permit(:first_name, :last_name, :user_name, :password, :password_confirmation, :league_id)
    end
    def update_standings
      Player.all.each do |player|
        if player.losses == 0 && player.wins == 0
          player.update(win_percentage: 0)
        elsif player.losses == 0
          player.update(win_percentage: 100)
        else
          d = player.wins + player.losses.to_f
        player.update win_percentage: (player.wins / d * 100).round(2)
        end
      end
    end
    def admin_access
      return redirect_to '/' if @current_player.nil? || @current_player.user_name != "admin"
    end
    def standings_array
      standings_array = [0]
      Player.all.each do |player|
        next if player.user_name == "admin"
        standings_array << player.standings_position
      end
      p standings_array.max + 1
    end
end
