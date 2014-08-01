module Resque
  module Plugins
    module JobStats
      # A class composed of a job class and the various job statistics
      # collected for the given job.
      class Statistic
        include Comparable

        # An array of the default statistics that will be displayed in the web tab
        DEFAULT_STATS = [
          :jobs_enqueued, :jobs_performed, :jobs_failed, :job_rolling_avg,
          :longest_job, :job_memory_usage_rolling_avg, :job_memory_usage_max
        ]

        attr_accessor *[:job_class].concat(DEFAULT_STATS)

        class << self
          # Find and load a Statistic for all resque jobs that are in the Resque::Plugins::JobStats.measured_jobs collection
          def find_all(metrics)
            Resque::Plugins::JobStats.measured_jobs.map{|j| new(j, metrics)}
          end
        end

        # A series of metrics describing one job class.
        def initialize(job_class, metrics)
          self.job_class = job_class
          self.load(metrics)
        end

        def load(metrics)
          metrics.each do |metric|
            self.send("#{metric}=", job_class.send(metric))
          end
        end

        def name
          self.job_class.name
        end

        def <=>(other)
          self.name <=> other.name
        end
      end
    end
  end
end
