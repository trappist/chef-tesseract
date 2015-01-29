#
# Cookbook Name:: tesseract
# Recipe:: default
#
# Copyright 2014, Takahiro Poly Horikawa
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
case node["platform"]
when "debian", "ubuntu"
  packages = %w(libtiff-dev libpng-dev libjpeg-dev autoconf libtool)
else
  packages = %w(libtiff-devel libpng-devel libjpeg-devel autoconf libtool)
end

packages.each do |pkg|
  package pkg do
    action :install
  end
end

remote_file "#{Chef::Config[:file_cache_path]}/leptonica.tar.gz" do
  source "https://leptonica.googlecode.com/files/leptonica-1.69.tar.gz"
end

bash "compile_leptonica_source" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxf leptonica.tar.gz
    cd leptonica-1.69
    ./configure
    make && make install
  EOH
  not_if { ::File.exists?("/usr/local/lib/liblept.so") }
  not_if { ::File.directory?("/usr/local/include/leptonica/") }
end

remote_file "#{Chef::Config[:file_cache_path]}/tesseract.tar.gz" do
  source "https://tesseract-ocr.googlecode.com/files/tesseract-ocr-3.02.02.tar.gz"
end

bash "compile_tesseract_source" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxf tesseract.tar.gz
    cd tesseract-ocr
    ./autogen.sh
    ./configure
    make && make install
  EOH
  not_if { ::File.exists?("/usr/local/bin/tesseract") }
end

execute "ldconfig" do
  command "/sbin/ldconfig"
end

remote_file "#{Chef::Config[:file_cache_path]}/tesseract.eng.tar.gz" do
  source "https://tesseract-ocr.googlecode.com/files/tesseract-ocr-3.02.eng.tar.gz"
end

bash "install_tesseract_english_language_pack" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxf tesseract.eng.tar.gz
    cd tesseract-ocr
    cp -rf tessdata /usr/local/share
  EOH
  not_if { ::File.exists?("/usr/local/share/tessdata/eng.traineddata") }
end
