#! /usr/bin/env ruby
#
#   check-docker-security
#
# DESCRIPTION:
# This check verifies the security of all of your Containers
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   check-docker-security.rb -h "http"://houndurl
#
# NOTES:
# Needs outbound access so that it can pull docker containers.
# Must be able to run containers with --priveleged flag
# This check takes a while to run, should only be ran once daily or weekly
#
# LICENSE:
#   Author Barry Martin <nyxcharon@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'

#
# Check Docker Conatiners for vuleranble bash and openssl
#
class CheckDockerContainers < Sensu::Plugin::Check::CLI
  option :hound,
         short: '-h houndurl'
  option :list,
         short: '-l list,of,images'
  option :image,
         short: '-i image',
         default: "nyxcharon/docker-audit"
  option :memory,
         short: '-m 256m',
         defaults: 'inf'
  option :cpushares,
         short: '-s 256',
         defaults: '1024'
  option :cpucores,
         short: '-c 0',
         defaults: '0-3'
  option :volume,
         short: '-v volume',
         defaults: ''


  def run #rubocop:disable all
      if not config[:hound] and not config[:list]
        warning "Must specify either hound url or list"
      end

      #Build the command string and then run the docker-audit container
      output=""
      command = "docker run --privileged -m #{config[:memory]} --cpuset-cpus=#{config[:cpucores]} --cpu-shares=#{config[:cpushares]} -e LOG=file  --entrypoint wrapdocker  --rm "
      if config[:volume]
        command += " -v #{config[:volume]}"
      end
      command += " #{config[:image]} docker-audit -v "

      if config[:hound]
        command += " -h \"#{config[:hound]}\""
      else
        command += "-l #{config[:list]}"
      end

      output=%x[#{command}]
      puts output
      if output.include?("Audit Passed")
        ok "Audit Passed"
      else
        critical "#{output}"
      end
  end
end
