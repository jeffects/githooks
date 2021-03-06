load "pre_commit/pre_commit_helper.rb"

RSpec.describe PreCommitHelper do
  describe ".directory_excluded_from_checks?" do
    it "should return false for a random directory" do
      expect(PreCommitHelper.directory_excluded_from_checks?("/home/foo/bar")).to be_falsey
    end

    it "should return true for an assets/**/vendor directory" do
      expect(PreCommitHelper.directory_excluded_from_checks?("/my/dir/assets/images/vendor/foo")).to be_truthy
    end

    it "should return false for an assets directory" do
      expect(PreCommitHelper.directory_excluded_from_checks?("/my/dir/assets/foo")).to be_falsey
    end
  end

  describe ".deactivation_message" do
    it "should return a valid disabling message" do
      expect(PreCommitHelper.deactivation_message("disable", "foo", "bar")).to include("To permanently disable for this repo, run\ngit config hooks.foo bar")
    end
  end

  describe ".project_type" do
    it "should return :ruby" do
      expect(PreCommitHelper.project_type).to eq :ruby 
    end
  end

  describe ".run_checker" do
    let(:checker) { double }
    let(:checker_class) { double }

    before do
      allow(checker).to receive(:class).and_return(checker_class)
      allow(checker_class).to receive(:deactivation_message).and_return("This is how we deactivate.")
    end
    
    context "with a checker which doesn't return errors for this project" do
      before do
        allow(checker).to receive(:errors?).and_return(false)
        allow(checker).to receive(:messages).and_return([])
        expect(checker).to receive(:errors?)
        expect(checker).to_not receive(:messages)
        expect(checker_class).to_not receive(:deactivation_message)
      end

      context "when passed false" do
        it "should return false" do
          expect(PreCommitHelper.run_checker(false, checker)).to be_falsy
        end
      end

      context "when passed true" do
        it "should return true" do
          expect(PreCommitHelper.run_checker(true, checker)).to be_truthy
        end
      end
    end

    context "with a checker which returns errors for this project" do
      before do
        allow(checker).to receive(:errors?).and_return(true)
        allow(checker).to receive(:messages).and_return(['a', 'b'])
        allow(checker).to receive(:deactivation_message).and_return(nil)
        expect(checker).to receive(:errors?)
        expect(checker).to receive(:messages)
        expect(checker_class).to receive(:deactivation_message)
      end

      context "when passed false" do
        it "should return true" do
          expect(PreCommitHelper.run_checker(false, checker)).to be_truthy
        end
      end

      context "when passed true" do
        it "should return true" do
          expect(PreCommitHelper.run_checker(true, checker)).to be_truthy
        end
      end
    end

    context "with a checker whithout a deactivation message" do
      before do
        allow(checker).to receive(:errors?).and_return(true)
        allow(checker).to receive(:messages).and_return(['a', 'b'])
        allow(checker).to receive(:deactivation_message).and_return(nil)
        allow(checker_class).to receive(:respond_to?).with(:deactivation_message).and_return(false)
        expect(checker).to receive(:errors?)
        expect(checker).to receive(:messages)
        expect(checker_class).to_not receive(:deactivation_message)
        
      end

      context "when passed false" do
        it "should return true" do
          expect(PreCommitHelper.run_checker(false, checker)).to be_truthy
        end
      end

    end
  end
end
