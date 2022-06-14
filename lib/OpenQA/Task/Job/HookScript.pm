# Copyright 2022 SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later

package OpenQA::Task::Job::HookScript;
use Mojo::Base 'Mojolicious::Plugin', -signatures;

sub register ($self, $app, $config) {
    $app->minion->add_task(hook_script => \&_hook_script);
}

sub _hook_script ($job, $hook, $openqa_job_id, $options) {
    my $timeout = $options->{timeout};
    my $kill_timeout = $options->{kill_timeout};
    my ($rc, $out) = _run_hook($hook, $openqa_job_id, $timeout, $kill_timeout);
    $job->note(hook_cmd => $hook, hook_result => $out, hook_rc => $rc);
    $job->retry if defined $rc && $rc == 42 && $job->retries < 2;
}

sub _run_hook ($hook, $openqa_job_id, $timeout, $kill_timeout) {
    my $out = qx{timeout -v --kill-after="$kill_timeout" "$timeout" $hook $openqa_job_id};
    return ($? >> 8, $out);
}

1;
