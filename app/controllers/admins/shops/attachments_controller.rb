class Admins::Shops::AttachmentsController <  Admins::Shops::SectionController

    #ajax upload file
    def upload
        file = params[:file].is_a?(ActionDispatch::Http::UploadedFile) ? params[:file] : params[:attachable]
        @attachment = Attachment.new
        @attachment.file = file
        begin
            @attachment.save!
            _attachment = @attachment.get_attributes(params[:version_name])
            render :json => { :success => true, :attachment => _attachment.to_json   }.to_json
        rescue Exception => e
            unless @attachment.new_record?
                path = File.dirname(@attachment.file.file.file)
                @attachment.file.remove!
                FileUtils.rm_rf(path)
                @attachment.destroy
            end
            render :json => { :success => false, :message => e.message }.to_json
        end
    end

    def destroy
        @attachment = Attachment.find(params[:id])
        @attachment.destroy
        render :json => { :success => true }.to_json
    end
end