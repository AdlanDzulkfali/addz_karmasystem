$(document).ready(function(){
  // LUA listener
  window.addEventListener('message', function( event ) {
    if (event.data.action == 'setWanted') {
      
      var bountyValue = event.data.bounty;

      $('#bounty').text(bountyValue);
      $('#wanted-poster').show();

    } else if (event.data.action == 'wantedClose') {
      $('#bounty').text('');
      $('#wanted-poster').hide();
    }
  });
});
