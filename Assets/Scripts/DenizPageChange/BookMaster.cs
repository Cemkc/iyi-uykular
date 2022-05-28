using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BookMaster : MonoBehaviour
{
    [Serializable]
    public struct Pages
    {
        public GameObject PageR;
        public GameObject PageL;
    }

    [SerializeField] private GameObject _bookCanvasL;
    [SerializeField] private GameObject _bookCanvasR;

    [SerializeField] private GameObject _pageR;
    [SerializeField] private GameObject _pageL;

    [SerializeField] private GameObject _canvasR;
    [SerializeField] private GameObject _canvasL;

    [SerializeField] private List<Pages> _pages;
    [SerializeField] private StageMaster _stageMaster;

    private enum BookStates { Idle, Flipping};
    private BookStates _bookState;

    private Animator _animatorPageR;
    private Animator _animatorPageL;

    [SerializeField] private int _pageNumber = 0;

    void Start()
    {
        _pageR.SetActive(false);
        _animatorPageR = _pageR.GetComponent<Animator>();

        _pageL.SetActive(false);
        _animatorPageL = _pageL.GetComponent<Animator>();

        Setup();
    }

    private void Setup()
    {
        _pageNumber = 0;
        LoadPageR();
        LoadPageL();
    }

    private void LoadPageR()
    {
        GameObject objR = Instantiate(_pages[_pageNumber].PageR, _canvasR.transform);

    }

    private void LoadPageL()
    {
        GameObject objL = Instantiate(_pages[_pageNumber].PageL, _canvasL.transform);
    }

    private void ClearPageR()
    {
        foreach (Transform obj in _canvasR.GetComponentsInChildren<Transform>())
        {
            if (obj != _canvasR.transform) { Destroy(obj.gameObject); }

        }       
    }

    private void ClearPageL()
    {
        foreach (Transform obj in _canvasL.GetComponentsInChildren<Transform>())
        {
            if (obj != _canvasL.transform) { Destroy(obj.gameObject); }

        }
    }

    public void FlipPageR()
    {
        if (_bookState == BookStates.Idle && _pageNumber < 1)
        {
            _bookState = BookStates.Flipping;
            _pageR.SetActive(true);
            _animatorPageR.SetBool("Flip", true);
            _pageNumber++;
        }

        if (_bookState == BookStates.Idle && _pageNumber == 1)
        {
            StartCoroutine(WaitDelay());
            _bookState = BookStates.Flipping;
            _pageR.SetActive(true);
            _animatorPageR.SetBool("Flip", true);
            _bookCanvasL.SetActive(false);
            _bookCanvasR.SetActive(false);
        }
    }

    IEnumerator WaitDelay()
    {
        yield return new WaitForSecondsRealtime(0.1f);
        _stageMaster.MoveCamera2();
        yield break;
    }

    public void FlipPageL()
    {
        if (_bookState == BookStates.Idle && _pageNumber > 0)
        {
            _bookState = BookStates.Flipping;
            _pageL.SetActive(true);
            _animatorPageL.SetBool("Flip", true);
            _pageNumber--;
        }
    }

    public void ActionR()
    {
        ClearPageR();
        LoadPageR();
    }

    public void ActionL()
    {
        ClearPageL();
        LoadPageL();
    }

    public void AnimationEndedR()
    {
        _pageR.SetActive(false);
        _animatorPageR.SetBool("Flip", false);
        _bookState = BookStates.Idle;
    }

    public void AnimationEndedL()
    {
        _pageL.SetActive(false);
        _animatorPageL.SetBool("Flip", false);
        _bookState = BookStates.Idle;
    }
}
