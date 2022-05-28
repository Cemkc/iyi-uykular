using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Starter : MonoBehaviour
{
    [SerializeField] StageMaster stg;

    public void Begin()
    {
        stg._test = true;
        gameObject.SetActive(false);
    }
}
