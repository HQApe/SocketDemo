/*
 * Copyright (C) 2016 即时通讯网(52im.net) The MobileIMSDK Project. 
 * All rights reserved.
 * Project URL:https://github.com/JackJiang2011/MobileIMSDK
 *  
 * 即时通讯网(52im.net) - 即时通讯技术社区! PROPRIETARY/CONFIDENTIAL.
 * Use is subject to license terms.
 */
package net.x52im.example.netty4.udp;

import io.netty.bootstrap.Bootstrap;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelOption;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.nio.NioDatagramChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;

public class EchoServer
{
	public static void main(String[] args) throws InterruptedException
	{
//		udpConnect();
		tcpConnect();
		
	}
	
	public static void udpConnect () throws InterruptedException {
		
		Bootstrap b = new Bootstrap();
		EventLoopGroup group = new NioEventLoopGroup();
		b.group(group)
			.channel(NioDatagramChannel.class)
//			.option(ChannelOption.SO_BROADCAST, true)
			.handler(new EchoSeverHandler());
		System.out.println("【NOTE】>>>>>> Netty UDP开始监听9999端口：");
		// 服务端监听在9999端口
		b.bind(9999).sync().channel().closeFuture().await();
		 
	}
	
	public static void tcpConnect () throws InterruptedException {
		
		//配置服务端Nio线程组  
        EventLoopGroup bossGroup = new NioEventLoopGroup();  
        EventLoopGroup workerGroup = new NioEventLoopGroup();  
        try{  
            ServerBootstrap b = new ServerBootstrap();  
            b.group(bossGroup, workerGroup)  
                .channel(NioServerSocketChannel.class)  
                .option(ChannelOption.SO_BACKLOG, 1024)
                .childHandler(new ChildChannelHandler());
            //绑定端口，同步等待成功  
            ChannelFuture f = b.bind(9999).sync();  
            System.out.println("【NOTE】>>>>>> Netty TCP开始监听9999端口：");
            //等待服务端监听端口关闭  
            f.channel().closeFuture().sync();  
        }finally{  
            //退出时释放资源  
            bossGroup.shutdownGracefully();  
            workerGroup.shutdownGracefully();  
        }         
	}
}
