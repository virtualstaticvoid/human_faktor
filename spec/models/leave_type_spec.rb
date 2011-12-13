require "spec_helper"

shared_examples_for 'non accuring leave type' do

  before do

    @leave_type.cycle_start_date = Date.new(2011, 1, 1)
    @leave_type.cycle_duration_unit = LeaveType::DURATION_UNIT_YEARS
    @leave_type.cycle_duration = 1
    @leave_type.cycle_days_allowance = 20

    @employee = Employee.new()
    @employee.start_date = Date.new(2011, 1, 1)

  end

  it "should not have absolute start and end dates for cycle" do
    @leave_type.has_absolute_start_date?.should be_false
  end

  it "should not carry over leave balances" do
    @leave_type.can_carry_over?.should be_false
  end

  it "should allow take on balances" do
    @leave_type.can_take_on?.should be_true
  end

  describe "cycle_start_date_for" do

    it "should be nil for dates prior to the employees start date" do
      @leave_type.cycle_start_date_for(Date.new(2010, 12, 31), @employee).should be_nil
    end

    it "should be the same as the employee start date" do
      @leave_type.cycle_start_date_for(Date.new(2011,  1, 1), @employee).should == Date.new(2011, 1, 1)
      @leave_type.cycle_start_date_for(Date.new(2011,  2, 1), @employee).should == Date.new(2011, 1, 1)
      @leave_type.cycle_start_date_for(Date.new(2011,  3, 1), @employee).should == Date.new(2011, 1, 1)
      @leave_type.cycle_start_date_for(Date.new(2011,  4, 1), @employee).should == Date.new(2011, 1, 1)
      @leave_type.cycle_start_date_for(Date.new(2011,  5, 1), @employee).should == Date.new(2011, 1, 1)
      @leave_type.cycle_start_date_for(Date.new(2011,  6, 1), @employee).should == Date.new(2011, 1, 1)
      @leave_type.cycle_start_date_for(Date.new(2011,  7, 1), @employee).should == Date.new(2011, 1, 1)
      @leave_type.cycle_start_date_for(Date.new(2011,  8, 1), @employee).should == Date.new(2011, 1, 1)
      @leave_type.cycle_start_date_for(Date.new(2011,  9, 1), @employee).should == Date.new(2011, 1, 1)
      @leave_type.cycle_start_date_for(Date.new(2011, 10, 1), @employee).should == Date.new(2011, 1, 1)
      @leave_type.cycle_start_date_for(Date.new(2011, 11, 1), @employee).should == Date.new(2011, 1, 1)
      @leave_type.cycle_start_date_for(Date.new(2011, 12, 1), @employee).should == Date.new(2011, 1, 1)
      @leave_type.cycle_start_date_for(Date.new(2012,  1, 1), @employee).should == Date.new(2012, 1, 1)
    end

    it "should increment by the cycle duration" do
      @leave_type.cycle_start_date_for(Date.new(2011, 1, 1), @employee).should == Date.new(2011, 1, 1)
      @leave_type.cycle_start_date_for(Date.new(2012, 1, 1), @employee).should == Date.new(2012, 1, 1)
      @leave_type.cycle_start_date_for(Date.new(2013, 1, 1), @employee).should == Date.new(2013, 1, 1)
      @leave_type.cycle_start_date_for(Date.new(2014, 1, 1), @employee).should == Date.new(2014, 1, 1)
      @leave_type.cycle_start_date_for(Date.new(2015, 1, 1), @employee).should == Date.new(2015, 1, 1)
      @leave_type.cycle_start_date_for(Date.new(2016, 1, 1), @employee).should == Date.new(2016, 1, 1)
    end
    
  end

  describe "cycle_end_date_for" do
    
    it "should be nil for dates prior to the employees start date" do
      @leave_type.cycle_end_date_for(Date.new(2010, 12, 31), @employee).should be_nil
    end

    it "should be the same as the employee start date plus the cycle duration" do
      @leave_type.cycle_end_date_for(Date.new(2011,  1, 1), @employee).should == Date.new(2011, 12, 31)
      @leave_type.cycle_end_date_for(Date.new(2011,  2, 1), @employee).should == Date.new(2011, 12, 31)
      @leave_type.cycle_end_date_for(Date.new(2011,  3, 1), @employee).should == Date.new(2011, 12, 31)
      @leave_type.cycle_end_date_for(Date.new(2011,  4, 1), @employee).should == Date.new(2011, 12, 31)
      @leave_type.cycle_end_date_for(Date.new(2011,  5, 1), @employee).should == Date.new(2011, 12, 31)
      @leave_type.cycle_end_date_for(Date.new(2011,  6, 1), @employee).should == Date.new(2011, 12, 31)
      @leave_type.cycle_end_date_for(Date.new(2011,  7, 1), @employee).should == Date.new(2011, 12, 31)
      @leave_type.cycle_end_date_for(Date.new(2011,  8, 1), @employee).should == Date.new(2011, 12, 31)
      @leave_type.cycle_end_date_for(Date.new(2011,  9, 1), @employee).should == Date.new(2011, 12, 31)
      @leave_type.cycle_end_date_for(Date.new(2011, 10, 1), @employee).should == Date.new(2011, 12, 31)
      @leave_type.cycle_end_date_for(Date.new(2011, 11, 1), @employee).should == Date.new(2011, 12, 31)
      @leave_type.cycle_end_date_for(Date.new(2011, 12, 1), @employee).should == Date.new(2011, 12, 31)
      @leave_type.cycle_end_date_for(Date.new(2012,  1, 1), @employee).should == Date.new(2012, 12, 31)
    end

    it "should increment by the cycle duration" do
      @leave_type.cycle_end_date_for(Date.new(2011, 1, 1), @employee).should == Date.new(2011, 12, 31)
      @leave_type.cycle_end_date_for(Date.new(2012, 1, 1), @employee).should == Date.new(2012, 12, 31)
      @leave_type.cycle_end_date_for(Date.new(2013, 1, 1), @employee).should == Date.new(2013, 12, 31)
      @leave_type.cycle_end_date_for(Date.new(2014, 1, 1), @employee).should == Date.new(2014, 12, 31)
      @leave_type.cycle_end_date_for(Date.new(2015, 1, 1), @employee).should == Date.new(2015, 12, 31)
      @leave_type.cycle_end_date_for(Date.new(2016, 1, 1), @employee).should == Date.new(2016, 12, 31)
    end

  end

  describe "leave_carried_forward_for" do
    
    it "should always be zero" do
      @leave_type.leave_carried_forward_for(@employee, Date.new(2011, 1, 1)).should == 0
      @leave_type.leave_carried_forward_for(@employee, Date.new(2012, 1, 1)).should == 0
      @leave_type.leave_carried_forward_for(@employee, Date.new(2013, 1, 1)).should == 0
      @leave_type.leave_carried_forward_for(@employee, Date.new(2014, 1, 1)).should == 0
    end

  end

  describe "allowance_for" do
    
    it "should be the full allowance for the cycle" do
      @leave_type.allowance_for(@employee, Date.new(2011,  1, 1)).should == 20
      @leave_type.allowance_for(@employee, Date.new(2011,  2, 1)).should == 20
      @leave_type.allowance_for(@employee, Date.new(2011,  3, 1)).should == 20
      @leave_type.allowance_for(@employee, Date.new(2011,  4, 1)).should == 20
      @leave_type.allowance_for(@employee, Date.new(2011,  5, 1)).should == 20
      @leave_type.allowance_for(@employee, Date.new(2011,  6, 1)).should == 20
      @leave_type.allowance_for(@employee, Date.new(2011,  7, 1)).should == 20
      @leave_type.allowance_for(@employee, Date.new(2011,  8, 1)).should == 20
      @leave_type.allowance_for(@employee, Date.new(2011,  9, 1)).should == 20
      @leave_type.allowance_for(@employee, Date.new(2011, 10, 1)).should == 20
      @leave_type.allowance_for(@employee, Date.new(2011, 11, 1)).should == 20
      @leave_type.allowance_for(@employee, Date.new(2011, 12, 1)).should == 20
    end

    context "employee with take on balance" do

      before do
        @employee.set_take_on_balance_for(@leave_type, 10)
        @employee.take_on_balance_as_at = Date.new(2011, 1, 1)
      end

      it "should be the take on balance for that cycle" do
        @leave_type.allowance_for(@employee, Date.new(2011, 1, 1)).should == 10
      end

      it "should be the allowance for subsequent cycles" do
        @leave_type.allowance_for(@employee, Date.new(2012, 1, 1)).should == 20
        @leave_type.allowance_for(@employee, Date.new(2013, 1, 1)).should == 20
      end
      
    end

  end

  describe "take_on_balance_for" do
    
  end

  describe "leave_taken_for" do
    
  end

  describe "leave_outstanding_for" do
    
  end

end

shared_examples_for 'accuring leave type' do

  before do

    @leave_type.cycle_start_date = Date.new(2011, 1, 1)
    @leave_type.cycle_duration_unit = LeaveType::DURATION_UNIT_YEARS
    @leave_type.cycle_duration = 1

    @employee = Employee.new()
    @employee.start_date = Date.new(2011, 1, 1)

  end

  it "should not have absolute start and end dates for cycle" do
    @leave_type.has_absolute_start_date?.should be_true
  end

  it "should not carry over leave balances" do
    @leave_type.can_carry_over?.should be_true
  end

  it "should allow take on balances" do
    @leave_type.can_take_on?.should be_true
  end


  describe "cycle_start_date_for" do
    
  end

  describe "cycle_end_date_for" do
    
  end

  describe "leave_carried_forward_for" do
    
  end

  describe "allowance_for" do
    
  end

  describe "take_on_balance_for" do
    
  end

  describe "leave_taken_for" do
    
  end

  describe "leave_outstanding_for" do
    
  end

end

shared_examples_for 'gender neutral leave type' do

  it "should not filter on gender" do
    @leave_type.gender_filter.length.should == 2
  end

end

shared_examples_for 'gender specific leave type' do

  it "should not filter on gender" do
    @leave_type.gender_filter.length.should == 1
  end

end

describe LeaveType::Educational do

  before do
    @leave_type = LeaveType::Educational.new()
  end

  it_should_behave_like 'non accuring leave type'
  it_should_behave_like 'gender neutral leave type'

end

describe LeaveType::Medical do

  before do
    @leave_type = LeaveType::Medical.new()
  end

  it_should_behave_like 'non accuring leave type'
  it_should_behave_like 'gender neutral leave type'

end

describe LeaveType::Maternity do

  before do
    @leave_type = LeaveType::Maternity.new()
  end

  it_should_behave_like 'non accuring leave type'
  it_should_behave_like 'gender specific leave type'

end

describe LeaveType::Compassionate do

  before do
    @leave_type = LeaveType::Compassionate.new()
  end

  it_should_behave_like 'non accuring leave type'
  it_should_behave_like 'gender neutral leave type'

end

describe LeaveType::Annual do

  before do
    @leave_type = LeaveType::Annual.new()
  end

  it_should_behave_like 'accuring leave type'
  it_should_behave_like 'gender neutral leave type'

end
