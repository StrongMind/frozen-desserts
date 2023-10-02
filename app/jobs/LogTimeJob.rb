class LogTimeJob < ApplicationJob
  queue_as :default

  def perform()
    print "LogTimeJob: " + Time.now.to_s + "\n"
  end
end