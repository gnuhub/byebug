module Byebug
  class PostMortemExample
    def a
      fail 'blabla'
    end
  end

  class PostMortemTestCase < TestCase
    def setup
      @example = lambda do
        byebug
        c = PostMortemExample.new
        c.a
      end

      super
    end

    def test_rises_before_exit_in_post_mortem_mode
      enter 'set post_mortem', 'cont', 'set nopost_mortem'
      assert_raises(RuntimeError) do
        debug_proc(@example)
      end
    end

    def test_post_mortem_mode_sets_post_mortem_flag_to_true
      enter 'set post_mortem', 'cont', 'set nopost_mortem'
      begin
        debug_proc(@example)
      rescue
        assert_equal true, Byebug.post_mortem?
      end
    end

    def test_execution_is_stopped_at_the_correct_line_after_exception
      enter 'set post_mortem', 'cont', 'set nopost_mortem'
      begin
        debug_proc(@example)
      rescue
        assert_equal 4, Byebug.raised_exception.__bb_line
      end
    end

    %w(step next finish break condition display tracevar
       untracevar).each do |cmd|
      define_method "test_#{cmd}_is_forbidden_in_post_mortem_mode" do
        enter 'set noautoeval', 'set post_mortem', "#{cmd}", 'set no_postmortem'
        Context.any_instance.stubs(:dead?).returns(:true)
        begin
          debug_proc(@example)
        rescue RuntimeError
          check_error_includes 'Command unavailable in post mortem mode.'
        end
      end
    end

    ['restart', 'frame', 'quit', 'edit', 'info', 'irb', 'source', 'help',
     'var class', 'list', 'method', 'kill', 'eval', 'set', 'save', 'show',
     'thread list', 'up', 'where', 'down'].each do |cmd|
      define_method "test_#{cmd}_is_permitted_in_post_mortem_mode" do
        enter 'set post_mortem', "#{cmd}", 'set no_postmortem'
        class_name = cmd.gsub(/(^| )\w/) { |b| b[-1, 1].upcase } + 'Command'

        Byebug.const_get(class_name).any_instance.stubs(:execute)
        assert_raises(RuntimeError) { debug_proc(@example) }
      end
    end
  end
end
