import 'package:flutter/material.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class GetServiceVideo extends StatefulWidget {
  final String videoUrl;
  const GetServiceVideo({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<GetServiceVideo> createState() => _GetServiceVideoState();
}

class _GetServiceVideoState extends State<GetServiceVideo> {
  late YoutubePlayerController _controller;

  @override
  Widget build(BuildContext context) {
    String url = widget.videoUrl;
    _controller = YoutubePlayerController(params: const YoutubePlayerParams(
      enableCaption: false, showControls: true, showVideoAnnotations: false, showFullscreenButton: false, loop: true,
    ))..onInit = () {
      _controller.loadVideo(url);
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      child: YoutubePlayer(
        controller: _controller,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

/*_controller.value.isInitialized ? ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(children: [
            VideoPlayer(_controller),
            Align(
              alignment: Alignment.center,
              child: FloatingActionButton(
                  backgroundColor: Theme.of(context).cardColor,
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying ? _controller.pause() : _controller.play();
                    });
                  },
                  child: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Theme.of(context).primaryColor,
                  ),
              ),
            ),
          ]),
        )) : const SizedBox();*/