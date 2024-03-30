unit SoundPlayer;

{$reference PresentationCore.dll}
uses Graph3D;
uses Utils;

type
  SoundPlayerT = class
  private
    m_player := new System.Windows.Media.MediaPlayer;
    m_knockFilename := System.IO.Directory.GetCurrentDirectory() 
      + '\res\sound\knock.mp3';
    uri: System.Uri;

  public
    constructor Create();
    begin 
      uri := new System.Uri(m_knockFilename);
      m_player.Open(uri);
    end;

    procedure PlayKnock();
    begin
      try
        logln('Sound: Knock Start');
        // перематываем в начало
        m_player.Position := System.TimeSpan.Zero;
        m_player.Play;
      except
        on e: System.Exception do
          logln('-----Error: ' + e.Message);
        else
          logln('-----Unknown Error');
      end;
    end;

  end;

type
  SoundHandlerT = class
  private
    static soundPlayer: SoundPlayerT;

  public
    static constructor;
    begin
      soundPlayer := new SoundPlayerT;
    end;

    static function GetSoundPlayer() : SoundPlayerT;
    begin
      Result := soundPlayer;
    end;

  end;

end.