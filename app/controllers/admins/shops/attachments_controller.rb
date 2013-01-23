class Admins::Shops::AttachmentsController <  Admins::Shops::SectionController
    
    #ajax upload file
    def upload        
        file = params[:file].is_a?(ActionDispatch::Http::UploadedFile) ? params[:file] : params[:attachable]
        attachment = Attachment.new
        attachment.attachable = file        
        begin
            attachment.save!          
            _attachment = attachment.attributes            
            _attachment[:url] = attachment.attachable.url("100x100")
            render :json => { :success => true, :attachment => _attachment.to_json   }.to_json
        rescue Exceoption => e
            attachment.attachable.remove!
            render :json => { :success => false }.to_json
        end
    end

    def destroy
        # attachment = Attachment.find(params[:id])
        # attachment.destroy
        render :json => { :success => true }.to_json
    end

    def testa
        render :json => { :success => true }.to_json
    end
end