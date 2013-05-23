define (["require","jquery","notify"],function(_re,$){
	require.config({catchError:true});
	require.onError = function(err){
		if (err.requireType === 'timeout'){

			alert(err);

		}else{
			showErr(err);
		}
	}

	function showErr(err){
		opts = {
			title: "Over Here",
			text: "Check me out. the program is timeout.",
			addclass: "stack-topleft",
			stack: stack_topright,
		};
		opts.title = "错误";
		opts.text = "加载页面错误:"+err.message+"请稍后重试";
		opts.type = "error";
		$.pnotify(opts);
	}
});