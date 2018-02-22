package com.kdab.training;
import org.qtproject.qt5.android.bindings.QtService;
import android.content.Intent;
import android.content.Context;

public class MyService extends QtService
{

    public static void startMyService(Context ctx)
    {
           ctx.startService(new Intent(ctx, MyService.class));
    }
}
