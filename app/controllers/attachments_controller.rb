class AttachmentsController < ApplicationController
	before_filter :login_or_admin_required

  def upload
    file = params[:file].is_a?(ActionDispatch::Http::UploadedFile) ? params[:file] : params[:attachable]
    @attachment = Attachment.new
    @attachment.file = file
    
    begin
      @attachment.save!
      render :text => {
        :success => true,
        :attachment => @attachment.as_json(version_name: params[:version_name])
      }.to_json
    rescue Exception => e
      unless @attachment.new_record?
        @attachment.file.remove!
        @attachment.destroy
      end
      render :text => {
        :success => false,
        :message => e.message
      }.to_json
    end
  end

  def destroy
    @attachment = Attachment.find(params[:id])
    @attachment.destroy
    render :json => { :success => true }.to_json
  end
end