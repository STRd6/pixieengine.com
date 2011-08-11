module Experimentable
  def self.included(controller)
    controller.class_eval do
      helper_method :experiment, :track_event
    end
  end

  # If the current user or session is in a treatment for the named experiment
  # returns true or false based on their assignment
  # otherwise assigns the current user or session to a treatment for the experiment
  def experiment(name)
    exp = Experiment.find_or_create_by_name(name)

    treatment = if current_user
      Treatment.find_or_create_by_experiment_id_and_user_id(exp.id, current_user.id)
    else
      Treatment.find_or_create_by_experiment_id_and_session_id(exp.id, request.session_options[:id])
    end

    !treatment.control
  end

  def track_event(name)
    if current_user
      Event.create(
        :name => name,
        :user => current_user
      )
    else
      Event.create(
        :name => name,
        :session_id => request.session_options[:id]
      )
    end
  end
end
