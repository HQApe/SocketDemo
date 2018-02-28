package net.x52im.example.netty4.udp;

import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelPipeline;
import io.netty.channel.socket.SocketChannel;
import io.netty.handler.codec.LengthFieldBasedFrameDecoder;
import io.netty.handler.codec.LengthFieldPrepender;
import io.netty.handler.codec.bytes.ByteArrayDecoder;
import io.netty.handler.codec.bytes.ByteArrayEncoder;
import io.netty.handler.codec.string.StringDecoder;
import io.netty.handler.codec.string.StringEncoder;
import io.netty.handler.timeout.IdleStateHandler;
import io.netty.util.CharsetUtil;

public class ChildChannelHandler extends ChannelInitializer<SocketChannel> {

	@Override
	protected void initChannel(SocketChannel channel) throws Exception {
		// TODO Auto-generated method stub
		ChannelPipeline pipeline = channel.pipeline();  
//        pipeline.addLast("frameDecoder", new LengthFieldBasedFrameDecoder(Integer.MAX_VALUE, 0, 4, 0, 4));  
//        pipeline.addLast("frameEncoder", new LengthFieldPrepender(4));  
//        pipeline.addLast("decoder", new StringDecoder(CharsetUtil.UTF_8));  
//        pipeline.addLast("encoder", new StringEncoder(CharsetUtil.UTF_8));
		
//		// Decoders  
//		pipeline.addLast("frameDecoder", new LengthFieldBasedFrameDecoder(1048576, 0, 4, 0, 4));  
        pipeline.addLast("bytesDecoder", new ByteArrayDecoder());  
//        // Encoder  
//        pipeline.addLast("frameEncoder", new LengthFieldPrepender(4));  
        pipeline.addLast("bytesEncoder", new ByteArrayEncoder());
        
        pipeline.addLast(new OutBoundHandler());  
        pipeline.addLast(new IdleStateHandler(0,0,300), new InBoundHandler()); 
	}

}
