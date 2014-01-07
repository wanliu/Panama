ActiveAdmin.register WithdrawMoney do 

  scope "未处理", default: true do
    WithdrawMoney.untreated
  end

  scope "处理失败" do
    WithdrawMoney.failer
  end

  scope "成功" do 
    WithdrawMoney.completed
  end

  index do 
    column :user
    column :money
    column "银行" do |row|
      "#{row.bank.bank_name} #{row.bank.code_title}"
    end
    column :arrive_mode do |row|
      I18n.t("withdraw_money.arrive_mode.#{row.arrive_mode.name}")
    end    
    column "操作" do |row|
      if row.state == :invalid
        link1 = link_to("完成", completed_system_withdraw_money_path(row), :class => "member_link succeed")
        link2 = link_to("失败", failer_system_withdraw_money_path(row), :class => "member_link failer")
        link1 + link2
      end
    end

    render :partial => "javascript"
  end


  member_action :completed, :method => :post do
    @withdraw = WithdrawMoney.find(params[:id])
    @withdraw.state = :succeed
    respond_to do |format|
      if @withdraw.save
        format.json{ head :no_content }
      else
        format.json{ render :json => draw_errors_message(@withdraw), :status => 403 }
      end
    end
  end

  member_action :failer, :method => :post  do 
    @withdraw = WithdrawMoney.find(params[:id])
    @withdraw.state = :failer
    respond_to do |format|
      if @withdraw.save
        format.json{ head :no_content }
      else
        format.json{ render :json => draw_errors_message(@withdraw), :status => 403 }
      end
    end
  end
end