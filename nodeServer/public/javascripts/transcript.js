function getTranscript(){
	var transcript_holder = $("#transcript_display");
	var fileId = transcript_holder.attr("data-file");

	$.ajax({
		type: 'GET',
		url: "http://localhost:3001/getTranscript/" + fileId,
	}).success(function(data) {
		var transcript = data.transcript
		for(var x in transcript){
			console.log(transcript[x].value);
			transcript_holder.append("<p>" + transcript[x].value + "</p>");
		}
	});
}

$( document ).ready(function() {
  getTranscript();
});