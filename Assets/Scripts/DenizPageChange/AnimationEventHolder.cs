using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationEventHolder : MonoBehaviour
{
    [SerializeField] private BookMaster _bookMaster;
    [SerializeField] private StageMaster _stageMaster;

    public void AnimationFinishedPageR()
    {
        _bookMaster.AnimationEndedR();
    }

    public void AnimationFinishedPageL()
    {
        _bookMaster.AnimationEndedL();
    }

    public void PageRAction()
    {
        _bookMaster.ActionR();
    }

    public void PageLAction()
    {
        _bookMaster.ActionL();
    }

    public void PageOpenFinished()
    {
        _stageMaster.RemoveOpenBookModel();
    }

    public void PageCloseFinished()
    {
        //FinishGame
    }

    public void PageOpenAction()
    {
        _stageMaster.SpawnFinalBookModel();
    }

    public void PageCloseAction()
    {
        _stageMaster.RemoveFinalBookModel();
    }
}
