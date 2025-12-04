unit AnimSeq;

uses Utils;

type
  AnimSeqT = class
  private
    m_actions := new Stack<Action0>;
    m_last : Action0 := nil;

  public
    procedure Run();
    begin
      logln('  AnimSeq is running');

      if m_actions.Count() <= 0 then begin
        m_last();
        logln('  AnimSeq is finished');
      end
      else begin
        logln('    Run action');
        var action : Action0 := m_actions.Pop();
        m_actions.Clear();
        action();
      end;
    end;

    procedure SetLast(p: Action0);
    begin
      m_last := p;
    end;

    procedure Add(p: Action0);
    begin
      m_actions.Push(p);
    end;

  end;

end.
