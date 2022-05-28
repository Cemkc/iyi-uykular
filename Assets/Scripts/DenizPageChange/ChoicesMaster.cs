using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class ChoicesMaster : MonoBehaviour
{
    [Serializable]
    public struct Choices
    {
        public GameObject Choice;
        [TextArea(2, 5)] public string Text;
    }

    [SerializeField] private List<Choices> _choices;
    [SerializeField] private TextMeshProUGUI _textField;

    public void LoadChoice(int index)
    {
        if (index <= _choices.Count - 1)
        {
            _choices[index].Choice.SetActive(true);
            _textField.SetText(_choices[index].Text);
        }
    }

    public void ClearChoice(int index)
    {
        _choices[index].Choice.SetActive(false);
        _textField.SetText("");
    }
}
