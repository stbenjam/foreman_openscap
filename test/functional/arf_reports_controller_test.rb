require 'test_plugin_helper'

class ArfReportsControllerTest < ActionController::TestCase
  setup do
    ForemanOpenscap::Helper.stubs(:find_name_or_uuid_by_host)
    ::ProxyAPI::Openscap.any_instance.stubs(:destroy_report).returns(true)
    @host = FactoryGirl.create(:compliance_host)
  end

  test "should delete arf report" do
    ForemanOpenscap::ArfReport.any_instance.stubs(:openscap_proxy).returns(@host.openscap_proxy)
    arf_report = FactoryGirl.create(:arf_report, :host_id => @host.id)
    assert_difference("ForemanOpenscap::ArfReport.count", -1) do
      delete :destroy, { :id => arf_report.id }, set_session_user
    end
    assert_redirected_to arf_reports_path
  end

  test "should delete multiple reports" do
    ForemanOpenscap::ArfReport.any_instance.stubs(:openscap_proxy).returns(@host.openscap_proxy)
    arf_reports = []
    3.times do
      arf_reports << FactoryGirl.create(:arf_report, :host_id => @host.id)
    end
    last_arf = arf_reports[-1]
    assert_difference("ForemanOpenscap::ArfReport.unscoped.count", -2) do
      post :submit_delete_multiple, { :arf_report_ids => arf_reports[0..-2].map(&:id) }, set_session_user
    end
    assert_redirected_to arf_reports_path
    assert_equal last_arf, ForemanOpenscap::ArfReport.unscoped.first
  end

  test "should download arf report as html" do
    arf_report = FactoryGirl.create(:arf_report, :host_id => @host.id)
    report_html = File.read("#{ForemanOpenscap::Engine.root}/test/files/arf_report/arf_report.html")
    ForemanOpenscap::ArfReport.any_instance.stubs(:to_html).returns(report_html)
    get :download_html, { :id => arf_report.id }, set_session_user
    assert_equal report_html, @response.body
  end
end
