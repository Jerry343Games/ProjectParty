using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectRotate : MonoBehaviour
{
    public float degreesPerSecond;
    public bool isHold;
    // Start is called before the first frame update
    void Start()
    {
        //isHold = false;
    }

    // Update is called once per frame
    void Update()
    {
        if (!isHold)
        {
            transform.Rotate(new Vector3(0f, Time.deltaTime * degreesPerSecond, 0f), Space.World);
        }
    }
}
