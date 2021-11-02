class SampleJob < ApplicationJob
  def perform
    Rails.logger.info('Performing SampleJob')
  end
end
