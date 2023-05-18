using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GraspGun : MonoBehaviour
{

    public GameObject gun;
    public Transform graspPoint;
    public GameObject player;
    public bool isGraspGun;
    public bool isHit;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        ReleaseGun();
    }

    void ReleaseGun()
    {
        if (isGraspGun&&isHit)
        {
            Debug.Log("Release");
            if (gun)
            {
                gun.transform.parent = null;
                gun.GetComponent<Rigidbody>().useGravity = true;
                //gun.GetComponent<MilkBoxSettings>().ableToTake = true;
                gun.GetComponent<ObjectRotate>().isHold = false;
                gun.GetComponent<SphereCollider>().enabled = true;
                isHit = false;
                StartCoroutine(Wait2GraspGun());
            }
        }
    }

    IEnumerator Wait2GraspGun()
    {
        yield return new WaitForSeconds(1f);
        isGraspGun = false;
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.transform.CompareTag("Gun"))
        {
            gun = collision.gameObject;

            gun.GetComponent<ObjectRotate>().isHold = true;
            gun.GetComponent<Rigidbody>().useGravity = false;
            collision.transform.parent = gameObject.transform;
            gun.GetComponent<Rigidbody>().velocity = Vector3.zero;
            gun.GetComponent<Rigidbody>().angularVelocity = Vector3.zero;
            gun.GetComponent<SphereCollider>().enabled = false;
            gun.transform.GetChild(0).transform.rotation = Quaternion.Euler(0, 0, 0);
            Debug.Log(gun.transform.GetChild(0).name);
            gun.transform.position = graspPoint.transform.position;
            isGraspGun = true;
        }
    }
}
