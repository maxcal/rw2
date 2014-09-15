# Sets up `text` and `html` variables that can be used to test the different parts of a multipart email
# expects a `let mail` to exist
RSpec.shared_context 'multipart email' do
  let(:html) do
    Capybara::Node::Simple.new( mail.body.parts.find {|p| p.content_type.match /html/}.body.raw_source )
  end
  let(:text) { mail.body.parts.find {|p| p.content_type.match /plain/}.body.raw_source }
end

