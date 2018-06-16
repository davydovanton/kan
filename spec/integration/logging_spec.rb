RSpec.describe 'logger support' do
  let(:logger) { spy }
  let(:app) do
    Kan::Application.new(
      logger: LoggerAbilities.new(logger: logger)
    )
  end

  class LoggerAbilities
    include Kan::Abilities

    register('info') do
      logger.info('Log read ability')
      true
    end
  end

  it do
    app['logger.info'].call
    expect(logger).to have_received(:info).with('Log read ability')
  end
end
