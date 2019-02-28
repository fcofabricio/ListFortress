class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :edit, :update]

  # GET /matches
  # GET /matches.json
  def index
    @matches = Match.all.paginate(page: params[:page], per_page: 25)
  end

  # GET /tournaments/1
  # GET /tournaments/1.json
  def show
    respond_to do |format|
      # @match = Match.where(id:params[:id])
      format.html
      format.csv { send_data  Match.where(id: params[:id]).to_csv, filename: "listfortress-#{@tournament.id}.csv"}
    end
  end

  # POST /matches
  # POST /matches.json
  def create
    @match = Match.new(match_params['match'])

    respond_to do |format|
      if @match.save
        update_parents(@match)
        format.html { redirect_to @match, notice: 'Match was successfully created.' }
        format.json { render :show, status: :created, location: @match }
      else
        format.html { render :new }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /matches/1
  # PATCH/PUT /matches/1.json
  def update
    respond_to do |format|
      if @match.league
        if match_params['player1_url_temp']
          xws = Participant.get_xws_from_url(match_params['player1_url_temp'])
          if xws.present?
            @match.player1_url = match_params['player1_url_temp']
            @match.player1_xws = xws
          end
        end
        if match_params['player2_url_temp']
          xws = Participant.get_xws_from_url(match_params['player2_url_temp'])
          if xws.present?
            @match.player2_url = match_params['player2_url_temp']
            @match.player2_xws = xws
          end
        end
      end

      if @match.update(match_params['match'])
        update_parents(@match)
        format.html { redirect_to @match, notice: 'Match was successfully updated.' }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      else
        format.html { render :edit, notice: "The record could not be updated" }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /matches/1
  # DELETE /matches/1.json
  def destroy
    @match.destroy
    respond_to do |format|
      format.html { redirect_to matches_url, notice: 'Match was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def update_parents(match)
    return if match.round.nil?

    round = Round.find_by(id: match.round_id)

    return if round.blank?

    round.touch
    tourney = Tournament.find_by(id: round.tournament_id)
    tourney.touch if tourney.present?
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_match
    @match = Match.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render(file: File.join(Rails.root, 'public/404.html'), status: 404, layout: false)
    # handle not found error
  rescue ActiveRecord::ActiveRecordError
    render(file: File.join(Rails.root, 'public/404.html'), status: 404, layout: false)
    # handle other ActiveRecord errors
  rescue StandardError
    render(file: File.join(Rails.root, 'public/404.html'), status: 404, layout: false)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def match_params
    params.permit(:id, match:
    [:player1_id, :player1_points, :player2_id, :player2_points, :result, :round_id, :winner_id]
  )
  end
end
