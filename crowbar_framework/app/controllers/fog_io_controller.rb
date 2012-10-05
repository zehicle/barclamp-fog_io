# Copyright 2012, Dell, Inc. 
# 
# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
# 
#  http://www.apache.org/licenses/LICENSE-2.0 
# 
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License. 
# 
require 'rubygems'
require 'fog'

class FogIoController < BarclampController
  
  def connection
    # lookup information about keystone
    configs = ProposalObject.find_proposals('keystone')
    if configs.length > 0
      config = configs.first["attributes"]["keystone"]
      server = configs.first.elements["keystone-server"]
      # this should go into a session eventually
      connection = Fog::Compute.new(
        :provider => 'OpenStack',
        :openstack_username => config["admin"]["username"],
        :openstack_api_key => config["admin"]["password"],
        :openstack_auth_url => "http://#{server}:5000/v2.0/tokens",
        :openstack_tenant => config["admin"]["tenant"]
      )
    end
  end

  def nodes
    @cloud = connection
    if request.post? 
      server = connection.servers.create(params)
      flash[:notice] = I18n.t((server ? 'create_success' : 'create_fail'), :scope=>'fog_io.nodes')
    end

    @flavors = {}
    @flavors_select = {}
    @cloud.flavors.sort_by(&:name).each do |f|
      @flavors_select[f.name] = f.id 
      @flavors[f.id] = f.name
    end
    @images = {}
    @images_select = {}
    @cloud.images.sort_by(&:name).each do |i| 
      @images_select[i.name] = i.id
      @images[i.id] = i.name
    end
    # create a connection
    respond_to do |format|
      format.html # index.html.haml
      format.json { render :json => "foo" }
    end
  end
  
end

