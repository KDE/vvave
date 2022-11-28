/******************************************************************************
**
** Copyright (C) 2022 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Qt Multimedia module.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or (at your option) the GNU General
** Public license version 3 or any later version approved by the KDE Free
** Qt Foundation. The licenses are as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-2.0.html and
** https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
******************************************************************************/

package org.vvave.mediasession;

import android.content.ComponentName;
import android.content.Context;
import android.media.MediaMetadata;
import android.media.session.MediaSession;
import android.media.session.MediaSessionManager;
import android.media.session.MediaController;
import android.media.session.PlaybackState;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.app.ActivityManager ;
import android.app.ActivityManager.RunningServiceInfo ;
import android.app.NotificationChannel ;
import android.app.NotificationManager;
import android.app.Notification;
import androidx.core.app.NotificationCompat;
import android.support.v4.media.MediaBrowserCompat;
import android.support.v4.media.session.MediaSessionCompat;
import android.support.v4.media.session.PlaybackStateCompat;

import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.media.AudioManager;
import android.net.Uri;

import android.content.ComponentName;

import org.qtproject.qt5.android.bindings.QtService;

import java.util.List;

public class QMediaSessionManager  extends QtService
{
    private final String TAG="VvaveMediaPlayer";
    private MediaSession mediaSession;
        private PlaybackState.Builder playbackStateBuilder;

        @Override
           public void onCreate() {
               super.onCreate();

               String CHANNEL_ID = "my_channel_01";
               NotificationChannel channel = new NotificationChannel(CHANNEL_ID,
                       "Channel human readable title",
                       NotificationManager.IMPORTANCE_DEFAULT);

               ((NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE)).createNotificationChannel(channel);

               Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                       .setContentTitle("VVVVVAVE")
                       .setContentText("its vvave bitcvh").build();


                               startForegroundService(new Intent(QMediaSessionManager.this, QMediaSessionManager.class));
               startForeground(5, notification);



 init();
               System.out.println(TAG + "Creating Service");
              Log.i(TAG, "Creating Service");
           }

           @Override
           public void onDestroy() {
               super.onDestroy();
               Log.i(TAG, "Destroying Service");
           }

           @Override
           public int onStartCommand(Intent intent, int flags, int startId) {
               int ret = super.onStartCommand(intent, flags, startId);

               System.out.println(TAG + "Creating Service");




               // Do some work
               init();

               return ret;
           }

       public static void startQtAndroidService(Context context) {
           System.out.println("STARTING VVAVE SERVICE MEDIASESSIIOn");

              ComponentName comp = context.startForegroundService(new Intent(context, QMediaSessionManager.class));

              if(comp == null)
              {
                  System.out.println("VVA EMEDIASESSION SERVICEFAILED");
              }else
          {
              System.out.println("STARTING VVAVE SERVICE MEDIASESSIIOn"+ comp.getClassName());
              }


       }


    private void init() {

        playbackStateBuilder =new PlaybackState.Builder();
               playbackStateBuilder.setActions(PlaybackState.ACTION_PLAY|PlaybackState.ACTION_PAUSE);


        mediaSession = new MediaSession(this, "Vvave");

        mediaSession.setFlags(MediaSession.FLAG_HANDLES_MEDIA_BUTTONS |
                MediaSession.FLAG_HANDLES_TRANSPORT_CONTROLS);

                System.out.println("TOKEN "+mediaSession.getSessionToken());

//                setSessionToken(mediaSession.getSessionToken());
                        mediaSession.setPlaybackState(playbackStateBuilder.build());

                        mediaSession.setCallback(new MediaSessionCallback());

                         mediaSession.setActive(true);
                          setPlaybackState(PlaybackState.STATE_STOPPED);

    }

private void setPlaybackState(int playbackState){
        playbackStateBuilder.setState(playbackState,0,1f);

        mediaSession.setPlaybackState(playbackStateBuilder.build());
    }

private class MediaSessionCallback extends MediaSession.Callback{
    @Override
    public void onPlay() {
        super.onPlay();
    }

    @Override
    public void onPause() {
        super.onPause();
    }

    @Override
    public void onPlayFromUri(Uri uri, Bundle extras) {
        super.onPlayFromUri(uri, extras);
    }

}

}
