# frozen_string_literal: true

shared_examples_for 'CI variable' do
  it { is_expected.to include_module(HasVariable) }

  describe "variable type" do
    it 'defines variable types' do
      expect(described_class.variable_types).to eq({ "env_var" => 1, "file" => 2 })
    end

    it "defaults variable type to env_var" do
      variable = create(described_class.table_name.singularize)
      file_variable = create(described_class.table_name.singularize, variable_type: 'file')

      expect(variable.reload.variable_type_before_type_cast).to eq(1)
      expect(file_variable.reload.variable_type_before_type_cast).to eq(2)
    end

    it "supports variable type file" do
      variable = described_class.new(variable_type: :file)
      expect(variable).to be_file
    end

    it 'provides variable type options' do
      expect(described_class.variable_type_options).to eq([%w(Variable env_var), %w(File file)])
    end
  end

  it 'strips whitespaces when assigning key' do
    subject.key = " SECRET "
    expect(subject.key).to eq("SECRET")
  end

  it 'can convert to runner variable' do
    expect(subject.to_runner_variable.keys).to include(:key, :value, :public, :file)
  end
end
