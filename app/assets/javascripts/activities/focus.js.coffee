# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

define ["jquery"],($,)->

	events:{
		"click .addLine" : "addLine"
	}

	addLine : ()->
		$("addLine").prepend("<div class='control-group' style='display: block;float: left;'>
		<label class='control-label' for='inputPeople'>人数</label>
		<div class='controls'><input class='span2' id='inputPeople' placeholder='人数' type='text'>
		</div></div><div class='control-group' style='display: block;float: left;'>
		<label class='control-label' style='width:120px;'  for='inputPrice'>数量</label>
		<div class='controls' style='margin-left:140px;'>
		<input class='span2' id='inputPrice' placeholder='价格'' type='text'>
		</div>
		</div>")