class CmmCallbacksController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:create]

  before_action :set_callback, only: [:show]
  before_action :set_user, :set_pa, :set_prescription, only: [:create]


  # GET /callbacks
  # GET /callbacks.json
  def index
    @callbacks = CmmCallback.order('created_at DESC').page(params[:page])
  end

  # GET /callbacks/1
  # GET /callbacks/1.json
  def show
    respond_to do |format|
      format.html { render :show }
      format.json { render json: @callback }
    end
  end

  # POST /callbacks.json {JSON body}
  # this is the method that is called directly by CoverMyMeds when a PA is created
  # retrospectively by a pharmacist. This method needs to create a new PA record in
  # the demo system, and respond appropriately, if it can match the PA to a prescription
  # that we created previously.

  # this method is also called whenever the status or a value of a property in the PA
  # changes. In that case, we need to update the PA record in our system with the
  # new values in the callback.
  def create
    handler = PaHandler.new(pa: @pa, user: @user, 
      prescription: @prescription, patient: @patient)

    case handler.call
    when :npi_not_found
      logger.debug "CmmCallbacksController: NPI #{request_params['prescriber']['npi']} not found."
      render(status: 410, text: 'NPI not found') and return
    when :prescription_not_found
      # systems may choose to reject unrecognized prescriptions, 
      # to add them to the system, or to have a un-attached PA
      # for this example, we have decided this is a paper Rx
      # so we want to handle PA electronically
      create_alert(@user, "NPI #{@user.npi} was found, but the prescription didn't match. Creating new Rx.")
      logger.debug "CmmCallbacksController: Prescription Not Found: #{request_params['id']}"
      @pa.init_from_callback(request_params)
    when :new_retrospective
      logger.debug "CmmCallbacksController: New Retrospective PA created #{request_params['id']}"
      @pa.init_from_callback(request_params)
    when :pa_found
      delete_or_update_pa!
    end
    callback = @pa.cmm_callbacks.build(content: request_params.to_json)

    respond_to do |format|
      if @pa.save
        format.html { render status: 200, nothing: true }
        format.json { render json: @pa }
      else
        format.html { render :error }
        format.json { render json: callback }
      end
    end
  end

  private

  def is_delete_request?(callback)
    (callback['events'] || []).any? { |ev| ev['type'] == 'DELETE' }
  end

  def request_params
    params.require(:request)
  end

  def set_callback
    @callback = CmmCallback.find(params[:id])
  end

  def create_alert(user, message)
    user.alerts.create(message: message)
  end

  def set_user
    @user ||= User.find_by_npi(request_params['prescriber']['npi'])
  end

  def set_pa
    @pa ||= PaRequest.find_or_initialize_by(cmm_id: request_params['id'])
  end

  def set_prescription
    pat = request_params['patient']
    @patient ||= Patient.where(first_name: pat['first_name'] , 
      last_name: pat['last_name'], date_of_birth: pat['date_of_birth']).first
    @prescription ||= @patient.prescriptions.where(drug_number: request_params['prescription']['drug_id']).first unless @patient.nil?
  end

  def delete_or_update_pa!
    # if we have a record of the PA, delete it if appropriate
    if is_delete_request?(request_params)
      logger.debug("PA request #{@pa.cmm_id} was deleted.")
      create_alert(@user, "PA request #{@pa.cmm_id} was deleted.")
      @pa.update_attributes(cmm_token: nil, cmm_id: nil)
    else
      # if it's not a delete, then it's an update
      logger.debug("PA request #{@pa.cmm_id} was updated.")
      create_alert(@user, "PA request #{@pa.cmm_id} was updated.")
      @pa.update_from_callback(request_params)
    end
  end
end
