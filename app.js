var twitter = require('ntwitter'),
    redis = require('redis');

var redis_client = redis.createClient();

var twit = new twitter({
  consumer_key: 'eEwzvQaqssOPEKYE8W0Kg',
  consumer_secret: 'yEGrxOPRaqwT0wR8jvYzNdq8qBxrELLzpFWBL4EB6nc',
  access_token_key: '157843432-XZVaK2YDd5KhcxsF1Cc66R5p75dYB8KFjzmEbkvY',
  access_token_secret: 'Qaq4kdghtBCuGIst4ZWFYRbO47wOsz4Bu4MUmcLdQc'
});

redis_client.on("error", function (err) {
  console.log("Redis Error " + err);
});


twit.stream('statuses/filter', {track: 'youtube'}, function(stream) {
  stream.on('data', function (data) {
    parse_urls(data.entities.urls);
  });
});

function parse_urls(urls) {
  for(var i in urls) {
    url = urls[i];

    var video_id;
    var expanded_url = url.expanded_url;

    if(!expanded_url) continue;

    var index1 = expanded_url.indexOf('youtube.com')
    var index2 = expanded_url.indexOf('youtu.be');

    if(index1 != -1) {
      var _url = expanded_url.split('?');
      var query = _url[_url.length-1];

      // TODO: Parse URL as query
      var v_i = query.indexOf('v=');
      if(v_i == -1) continue;

      video_id = query.substring(v_i+2, v_i+2+11);
    }
    else if(index2 != -1) {
      var _url = expanded_url.split('/');
      video_id = _url[_url.length-1].substring(0,11);
    } else {
      continue;
    }

    if(video_id.length != 11) continue;

    console.log(video_id+'     '+expanded_url);
    store_video(video_id);
  }
}

function store_video(video_id) {
  redis_client.zscore('trending', video_id, function (err, score) {
    if(err) {
      console.log("Error: "+err);
      return;
    }

    var method;

    if(score != null) {
      method = 'zincrby';
    } else {
      method = 'zadd';
    }

    redis_client[method](['trending', 1, video_id], function(err, response) {
      if(err) {
        console.log("Error: "+err);
        return;
      }
      console.log(video_id+"="+response);
    });
  });
}
