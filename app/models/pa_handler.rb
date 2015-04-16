class PaHandler
  def initialize(pa: pa, user: user, prescription: prescription)
    @user = user
    @pa = pa
    @prescription = prescription
  end

  def pa_status(status)
    OpenStruct.new(status: status)
  end

  def call
    if !npi_found?
      pa_status(:npi_not_found)
    elsif !found_prescription?
      pa_status(:prescription_not_found)
    elsif @pa.new_record?
      pa_status(:new_retrospective)
    else
      pa_status(:pa_found)
    end
  end

  private

  def npi_found?
    @user.present?
  end

  def found_prescription?
    npi_found? && @prescription.present?
  end
end
