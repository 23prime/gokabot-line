describe Weather do
  base_msg_cases = %w[天気 今日の天気 明日の天気]

  before do
    @user_id = 'SAMPLE_USER_ID'
    @name = 'SAMPLE_NAME'
    @weather = Weather.new
    @default_city = Weather.get_default_city
    @changed_city = 'つくば'
    @unavailable_city = 'ほげほげ'
  end

  context "Default city: '#{@default_city}'" do
    base_msg_cases.each do |msg|
      it "[Base msg = #{msg}]" do
        ans = @weather.answer(msg, @user_id, @name)
        expect(ans).to include @default_city
      end
    end
  end

  context "Changed city: '#{@changed_city}'" do
    base_msg_cases.each do |msg|
      it "[Base msg = #{msg}]" do
        msg += ' ' + @changed_city
        ans = @weather.answer(msg, @user_id, @name)
        expect(ans).to include @changed_city
      end
    end
  end

  context 'Unavailable city name' do
    base_msg_cases.each do |msg|
      it "[Base msg = #{msg}" do
        msg += ' ' + @unavailable_city
        ans = @weather.answer(msg, @user_id, @name)
        expect(ans).to eq '分かりませ〜んｗ'
      end
    end
  end

  context 'Reset city to default' do
    it 'After changed' do
      msg = '天気 ' + @changed_city
      ans = @weather.answer(msg, @user_id, @name)
      expect(ans).to include @changed_city

      msg = '天気'
      ans = @weather.answer(msg, @user_id, @name)
      expect(ans).to include @default_city
    end

    it 'After unavailable' do
      msg = '天気 ' + @unavailable_city
      ans = @weather.answer(msg, @user_id, @name)
      expect(ans).to eq '分かりませ〜んｗ'

      msg = '天気'
      ans = @weather.answer(msg, @user_id, @name)
      expect(ans).to include @default_city
    end
  end
end
