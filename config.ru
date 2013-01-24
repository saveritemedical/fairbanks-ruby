require 'rubygems'
require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require File.expand_path(File.dirname(__FILE__) + '/lib/config')
require './init.rb'

run Sinatra::Application
