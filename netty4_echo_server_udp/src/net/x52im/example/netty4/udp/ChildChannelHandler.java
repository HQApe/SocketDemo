package net.x52im.example.netty4.udp;

import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelPipeline;
import io.netty.channel.socket.SocketChannel;
import io.netty.handler.codec.LengthFieldBasedFrameDecoder;
import io.netty.handler.codec.LengthFieldPrepender;
import io.netty.handler.codec.bytes.ByteArrayDecoder;
import io.netty.handler.codec.bytes.ByteArrayEncoder;
import io.netty.handler.codec.http.HttpObjectAggregator;
import io.netty.handler.codec.http.HttpServerCodec;
import io.netty.handler.codec.http.websocketx.WebSocketServerProtocolHandler;
import io.netty.handler.codec.string.StringDecoder;
import io.netty.handler.codec.string.StringEncoder;
import io.netty.handler.stream.ChunkedWriteHandler;
import io.netty.handler.timeout.IdleStateHandler;
import io.netty.util.CharsetUtil;

public class ChildChannelHandler extends ChannelInitializer<SocketChannel> {

	@Override
	protected void initChannel(SocketChannel channel) throws Exception {
		// TODO Auto-generated method stub
 
//		socket(channel);
		webSocket(channel);
	}
	
	public static void socket(SocketChannel channel) {
		ChannelPipeline pipeline = channel.pipeline();  
//      pipeline.addLast("frameDecoder", new LengthFieldBasedFrameDecoder(Integer.MAX_VALUE, 0, 4, 0, 4));  
//      pipeline.addLast("frameEncoder", new LengthFieldPrepender(4));  
//      pipeline.addLast("decoder", new StringDecoder(CharsetUtil.UTF_8));  
//      pipeline.addLast("encoder", new StringEncoder(CharsetUtil.UTF_8));
		
//		// Decoders  
//		pipeline.addLast("frameDecoder", new LengthFieldBasedFrameDecoder(1048576, 0, 4, 0, 4));  
      pipeline.addLast("bytesDecoder", new ByteArrayDecoder());  
//      // Encoder  
//      pipeline.addLast("frameEncoder", new LengthFieldPrepender(4));  
      pipeline.addLast("bytesEncoder", new ByteArrayEncoder());
      
      pipeline.addLast(new OutBoundHandler());  
      pipeline.addLast(new IdleStateHandler(0,0,300), new InBoundHandler());
	}
	
	public static void webSocket(SocketChannel channel) {
		ChannelPipeline pipeline = channel.pipeline();

        //websocket协议本身是基于http协议的，所以这边也要使用http解编码器
        pipeline.addLast(new HttpServerCodec());
        //以块的方式来写的处理器
        pipeline.addLast(new ChunkedWriteHandler());
        //netty是基于分段请求的，HttpObjectAggregator的作用是将请求分段再聚合,参数是聚合字节的最大长度
        pipeline.addLast(new HttpObjectAggregator(8192));

        //ws://server:port/context_path
        //ws://localhost:9999/ ，可以再后面加路劲WebSocketServerProtocolHandler("路劲")
        //参数指的是contex_path
        pipeline.addLast(new WebSocketServerProtocolHandler("/"));
        //websocket定义了传递数据的6中frame类型
        pipeline.addLast(new InBoundHandler());
	}

}
