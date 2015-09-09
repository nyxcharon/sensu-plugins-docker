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

  def run #rubocop:disable all
      if not config[:hound] and not config[:list]
        warning "Must specify either hound url or list"
      end

      #Run the docker-audit container
      output=""
      if config[:hound]
        output=%x[docker run --privileged -e LOG=file --entrypoint wrapdocker --rm "#{config[:image]}"  docker-audit -h "#{config[:hound]}"]
      end

      if output.include?("Audit Passed")
        ok "Audit Passed"
      else
        critical "#{output}"
      end
  end
end
